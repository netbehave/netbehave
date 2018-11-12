#
# Copyright 2018: Yves B. Desharnais
#
# This file is part of NetBehave available at NetBehave.org.
# 
# NetBehave is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# NetBehave is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with NetBehave.  If not, see <https://www.gnu.org/licenses/>.
# 

require "fluent/plugin/output"
# require "socket"
require 'sqlite3'
# require 'JSON'

# TODO: cache ttl
# TODO: storage

module Fluent
  module Plugin
    class FlowDailyDBOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("FlowDailyDB", self)


    			config_param :outputPath, :string,  default: '/tmp'
    
                def configure(conf)
                        super
                        
                        @dbPath = outputPath
						log.info "out_FlowDB, dbPath = [#{@dbPath}]"
	
                        now = DateTime.now
						@yyyymmdd = now.strftime("%Y-%m-%d")

						@localIPs = {}
						@destLabel = ""
#						log.info "out_FlowAsset1", local_network_name:local_network_name
#						log.info "out_FlowAsset2", local_network_name:@local_network_name
                end
                def start
                    super
#                    connect
					dbOpen

                end
                def shutdown
                    super
                    dbClose
#						log.info "FlowAsset", asset:value
                        
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

				def dbClose
					if !@db.nil?
						@db.close
						@db = nil
					end
				end 
				def dbOpen
					if @dbPath.end_with?("/")
						path = "#{@dbPath}flows-#{@yyyymmdd}.sqlite3"
					else
						path = "#{@dbPath}/flows-#{@yyyymmdd}.sqlite3"
					end
					log.info "out_FlowAnalysis, OpenDatabase file #{path}"

					@db = FlowDB.new(path)
	
				end

				def setDBdate(rtimestr)
					dbClose
					@yyyymmdd = rtimestr
					dbOpen
				end

				def handle_record(tag, time, record)
# time is  Fluent::EventTime	https://www.rubydoc.info/gems/fluentd/Fluent/EventTime
# http://stevenyue.com/blogs/date-time-datetime-in-ruby-and-rails/
# log.warn "time is [#{time.inspect}]"


#					rtime = Date.strptime(time.to_s, "%Y-%m-%dT%H:%M:%S-04:00") # time.to_time
					rtime = Time.at(time.to_int)
					rtimestr = rtime.strftime("%Y-%m-%d")
					if @yyyymmdd != rtimestr
						setDBdate rtimestr
					end
					
					hits = @db.sqlExists(record["flow"])
					if hits > 0
						@db.sqlUPDATE(record["flow"], time, hits)
					else
						@db.sqlINSERT(record["flow"], time)
					end
#					puts "records: #{@FlowDB.sqlExists  record["flow"]}"

				end # def handle_record
    



    end # class
    

class FlowDB
	def initialize(dbFilePath)
		@db = ::SQLite3::Database.open dbFilePath
		sqlCREATE
	end
	
	def self.finalize(bar)
#    proc {  puts "DESTROY OBJECT #{bar}" }
		proc {  @db.close }
	end

	def close()
		@db.close
	end
	
	def sqlCREATE()
	rows = @db.execute <<-SQL 
			CREATE TABLE IF NOT EXISTS flow 
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
	end
	
	def sqlINSERT(flow, time)
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
		rows = @db.execute("INSERT INTO flow (srcip, dstip, proto, srcport, dstport, srcdomain, dstdomain, srcnetwork, dstnetwork, servicename, match, dateAdded, dateLastSeen, hits, bytes) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?)", 
			[flow["src"]["ip"].to_s, flow["dst"]["ip"].to_s, flow["protocol_name"], flow["src"]["port"].to_i, flow["dst"]["port"].to_i, srcdomain, dstdomain, srcnetwork, dstnetwork, servicename, match, time.to_i, time.to_i, bytes])
	end #def

	def sqlUPDATE(flow, time, hits)
#		@@logger.debug "SQL.INSERT #{flow.inspect}"
		srcdomain = flow["src"]["domain"].nil? ? "" : flow["src"]["domain"]
		dstdomain = flow["dst"]["domain"].nil? ? "" : flow["dst"]["domain"]
		if flow["bytes"].nil? || flow["bytes"] == ""
			bytes = 0
		else
			bytes = flow["bytes"].to_i
		end
		newbytes = bytes + sqlBytes(flow)
		rows = @db.execute("UPDATE flow SET dateAdded = ?, dateLastSeen = ?, hits = ?, bytes = ? WHERE srcip = ? AND dstip = ? AND proto = ? AND srcport = ? AND dstport = ? AND srcdomain = ? AND dstdomain = ?",
			[time.to_i, time.to_i], hits + 1, newbytes, flow["src"]["ip"].to_s, flow["dst"]["ip"].to_s, flow["protocol_name"], flow["src"]["port"].to_i, flow["dst"]["port"].to_i, srcdomain, dstdomain)	
	end #def
	
	
	def sqlBytes(flow)
		srcdomain = flow["src"]["domain"].nil? ? "" : flow["src"]["domain"]
		dstdomain = flow["dst"]["domain"].nil? ? "" : flow["dst"]["domain"]
		rows = @db.execute("SELECT bytes FROM flow WHERE srcip = ? AND dstip = ? AND proto = ? AND srcport = ? AND dstport = ? AND srcdomain = ? AND dstdomain = ?",
			flow["src"]["ip"].to_s, flow["dst"]["ip"].to_s, flow["protocol_name"], flow["src"]["port"].to_i, flow["dst"]["port"].to_i, srcdomain, dstdomain)
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
		return row[0].to_i
	end
	
	def sqlExists(flow)
		srcdomain = flow["src"]["domain"].nil? ? "" : flow["src"]["domain"].to_s
		dstdomain = flow["dst"]["domain"].nil? ? "" : flow["dst"]["domain"].to_s
		rows = @db.execute("SELECT sum(hits) FROM flow WHERE srcip = ? AND dstip = ? AND proto = ? AND srcport = ? AND dstport = ? AND srcdomain = ? AND dstdomain = ?",
			flow["src"]["ip"].to_s, flow["dst"]["ip"].to_s, flow["protocol_name"].to_s, flow["src"]["port"].to_i, flow["dst"]["port"].to_i, srcdomain, dstdomain)
		if rows.nil?
#puts "s1"	
			return 0
		end
		if rows.length == 0 
#puts "s2"	
			return 0
		end
		row = rows[0]
#puts "s3"	
		if row[0].nil? || row[0] == ""
# puts "s4 #{flow.inspect}"	
			return 0
		end
# puts "s5"	
		
		return row[0] # "hits"
	end #def


end # class
    
  end # module
end # module

=begin

=end