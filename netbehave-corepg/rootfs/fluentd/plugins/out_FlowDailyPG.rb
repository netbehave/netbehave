#
# Copyright 2019: Yves Desharnais
# Part of NetBehave.org system
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require "fluent/plugin/output"
# require "socket"
require 'pg'
# require 'JSON'

# TODO: cache ttl
# TODO: storage

require_relative 'pg_classes' # .rb


module Fluent
  module Plugin
    class FlowDailyPGOutput < Fluent::Plugin::Output
    	include PgClasses # mixin used since multiple inheritance is not possible in Ruby
    	# includes: dbOpen, dbClose
      Fluent::Plugin.register_output("FlowDailyPG", self)

    			config_param :dbhost, :string,  default: 'localhost'
    			config_param :dbname, :string,  default: 'postgres'
    			config_param :dbuser, :string,  default: 'postgres'
    			config_param :dbpass, :string,  default: 'postgres'
    
                def configure(conf)
                        super
                        now = DateTime.now
						@yyyymmdd = now.strftime("%Y-%m-%d")
						@dates = {}

						@localIPs = {}
						@destLabel = ""
                end
                def start
                    super
                end
                def shutdown
                    super
                    dbClose
                end

				def emit(tag, es, chain)
					es.each do |time, record|
						handle_record(tag, time, record)
					end
					chain.next
				end # def emit

				def process(tag, es)
					es.each do |time, record|
						handle_record(tag, time, record)
					end
				end # def process

			private


				def setDBdate(rtimestr)
					dbClose
					@yyyymmdd = rtimestr
#					dbOpen
				end

				def handle_record(tag, time, record)
# time is  Fluent::EventTime	https://www.rubydoc.info/gems/fluentd/Fluent/EventTime
# http://stevenyue.com/blogs/date-time-datetime-in-ruby-and-rails/
# log.warn "time is [#{time.inspect}]"
#					rtime = Date.strptime(time.to_s, "%Y-%m-%dT%H:%M:%S-04:00") # time.to_time
					rtime = Time.at(time.to_int)
					rtimestr = rtime.strftime("%Y%m%d")
					rdate = rtimestr.to_i
					if @yyyymmdd != rtimestr
						setDBdate rtimestr
					end
					
					if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
						hits = sqlExists(record["flow"], rdate)
						if hits > 0
							sqlUPDATE(record["flow"], time, hits, rdate)
						else
							sqlINSERT(record["flow"], time, rdate)
						end
					else
						log.error "FlowDailyPGOutput:handle_record() Database not open"
					end
#					puts "records: #{@FlowDB.sqlExists  record["flow"]}"

				end # def handle_record
    

	def sqlCREATE()
		if !@dates.key?(@yyyymmdd) 
	rows = @db.exec <<-SQL 
			CREATE TABLE IF NOT EXISTS flow#{@yyyymmdd} 
			(
				srcip varchar(20),
				dstip varchar(20),
				proto varchar(10),
				srcport int,
				dstport int,
				srcdomain varchar(200),
				dstdomain varchar(200),
				
				srcnetwork varchar(200),
				dstnetwork varchar(200),
				servicename varchar(200),
				match varchar(200),
				dateAdded int,
				dateLastSeen int,
				hits int,
				bytes int,
  				PRIMARY KEY (srcip, dstip, proto, srcport, dstport, srcdomain, dstdomain)

			);
        SQL
			@dates[@yyyymmdd] = @yyyymmdd
		end


	end # sqlCREATE
	
	def sqlINSERT(flow, time, rdate)
		if @yyyymmdd != rdate
			setDBdate rdate
		end

		if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
	#		@@logger.debug "SQL.INSERT #{flow.inspect}"
			srcdomain = flow["src"]["domain"].nil? ? "" : flow["src"]["domain"]
			dstdomain = flow["dst"]["domain"].nil? ? "" : flow["dst"]["domain"]
			srcnetwork = flow["src"]["network"].nil? ? "" : flow["src"]["network"]
			dstnetwork = flow["dst"]["network"].nil? ? "" : flow["dst"]["network"]
			servicename = flow["serviceName"].nil? ? "" : flow["serviceName"]
			match = flow["match"].nil? ? "" : flow["match"]
	#		bytes = flow["bytes"].nil? ? 0 : flow["bytes"]
			if flow["bytes"].nil? || flow["bytes"] == ""
				bytes = 0
			else
				bytes = flow["bytes"].to_i
			end
		
	# puts "sqlINSERT match=[#{match}]"
			rows = @db.exec_params("INSERT INTO flow#{rdate}  (srcip, dstip, proto, srcport, dstport, srcdomain, dstdomain, srcnetwork, dstnetwork, servicename, match, dateAdded, dateLastSeen, bytes, hits) VALUES($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, 1)", 
				[flow["src"]["ip"].to_s, flow["dst"]["ip"].to_s, flow["protocol_name"], flow["src"]["port"].to_i, flow["dst"]["port"].to_i, srcdomain, dstdomain, srcnetwork, dstnetwork, servicename, match, time.to_i, time.to_i, bytes])
		else
			log.error "FlowDailyPGOutput:sqlINSERT() Database not open"
		end
	end #def

	def sqlUPDATE(flow, time, hits, rdate)
		if @yyyymmdd != rdate
			setDBdate rdate
		end
		if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
	#		@@logger.debug "SQL.INSERT #{flow.inspect}"
			srcdomain = flow["src"]["domain"].nil? ? "" : flow["src"]["domain"]
			dstdomain = flow["dst"]["domain"].nil? ? "" : flow["dst"]["domain"]
			if flow["bytes"].nil? || flow["bytes"] == ""
				bytes = 0
			else
				bytes = flow["bytes"].to_i
			end
			newbytes = bytes + sqlBytes(flow, rdate)
			rows = @db.exec_params("UPDATE flow#{rdate} SET dateAdded = $1, dateLastSeen = $2, hits = $3, bytes = $4 WHERE srcip = $5 AND dstip = $6 AND proto = $7 AND srcport = $8 AND dstport = $9 AND srcdomain = $10 AND dstdomain = $11",
				[time.to_i, time.to_i, hits + 1, newbytes, flow["src"]["ip"].to_s, flow["dst"]["ip"].to_s, flow["protocol_name"], flow["src"]["port"].to_i, flow["dst"]["port"].to_i, srcdomain, dstdomain])	
		else
			log.error "FlowDailyPGOutput:sqlUPDATE() Database not open"
		end
	end #def
	
	def sqlExists(flow, rdate)
		if @yyyymmdd != rdate
			setDBdate rdate
		end
		if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
			srcdomain = flow["src"]["domain"].nil? ? "" : flow["src"]["domain"].to_s
			dstdomain = flow["dst"]["domain"].nil? ? "" : flow["dst"]["domain"].to_s
			results = @db.exec_params("SELECT sum(hits) as sumhits FROM flow#{rdate} WHERE srcip = $1 AND dstip = $2 AND proto = $3 AND srcport = $4 AND dstport = $5 AND srcdomain = $6 AND dstdomain = $7",
				[flow["src"]["ip"].to_s, flow["dst"]["ip"].to_s, flow["protocol_name"].to_s, flow["src"]["port"].to_i, flow["dst"]["port"].to_i, srcdomain, dstdomain])
			rows = results.values
			if rows.nil?
	#puts "s1"	
				return 0
			end
			if rows.length == 0 
	#puts "s2"	
				return 0
			end
	# puts "s3 #{rows.length}"	
			row = rows[0]
			if row[0].nil? || row[0] == ""
	# puts "s4 #{flow.inspect}"	
				return 0
			end
	#puts "sqlExists rows #{rows}" 	
	#puts "sqlExists row  #{row}" 	
		
			return row[0].to_i # ['sumhits'].to_i # "hits"
		else
			log.error "FlowDailyPGOutput:sqlExists() Database not open"
		end
		return 0
	end #def

	# TODO: private???
	def sqlBytes(flow, rdate)
		if @yyyymmdd != rdate
			setDBdate rdate
		end
		if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
			srcdomain = flow["src"]["domain"].nil? ? "" : flow["src"]["domain"]
			dstdomain = flow["dst"]["domain"].nil? ? "" : flow["dst"]["domain"]
			results = @db.exec_params("SELECT bytes FROM flow#{rdate} WHERE srcip = $1 AND dstip = $2 AND proto = $3 AND srcport = $4 AND dstport = $5 AND srcdomain = $6 AND dstdomain = $7 ",
				[flow["src"]["ip"].to_s, flow["dst"]["ip"].to_s, flow["protocol_name"], flow["src"]["port"].to_i, flow["dst"]["port"].to_i, srcdomain, dstdomain])
			rows = results.values

			if rows.nil?
				return 0
			end
			if rows.length == 0 
				return 0
			end
			row = rows[0]
			if row[0].nil? || row[0] == ""
				return 0
			end
	#puts "sqlBytes rows #{rows}" 	
	#puts "sqlBytes row  #{row}" 	
	#puts "sqlBytes row['bytes']  #{row['bytes']}" 	
	#		return row['bytes'].to_i
			return row[0].to_i 
		else
			log.error "FlowDailyPGOutput:sqlBytes() Database not open"
		end	
		return 0
	end # def
    end # class
    
  end # module
end # module