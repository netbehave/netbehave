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
require_relative 'nbacl_classes_pg' # .rb

module Fluent
  module Plugin
    class FlowPass1Output < Fluent::Plugin::Output
    	include PgClasses # mixin used since multiple inheritance is not possible in Ruby
    	# includes: dbOpen, dbClose
		      Fluent::Plugin.register_output("FlowPass1", self) 

    			config_param :saveRulesDetail, :bool,  default: false
    			config_param :dbhost, :string,  default: 'localhost'
    			config_param :dbname, :string,  default: 'postgres'
    			config_param :dbuser, :string,  default: 'postgres'
    			config_param :dbpass, :string,  default: 'postgres'
    
                def configure(conf)
					super
					now = DateTime.now
					@yyyymmdd = now.strftime("%Y%m%d")
					@dates = {}

					@localIPs = {}
					@destLabel = ""
					@rulesCombinedFlows = nil
					@rulesFlows = nil
                    if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)	
						dbLoad
                    end
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
			
				def dbLoad
					begin
						if @rulesCombinesFlows.nil?
							log.info "FlowPass1Output::dbLoad rulesCombinesFlows #{@dbhost}/#{@dbname}"
							@rulesCombinedFlows = COMBINED_FLOWS.new(@dbhost, @dbname, @dbuser, @dbpass)
							# log.debug @rulesCombinedFlows.rules_to_s
						end
						if @rulesFlows.nil?
							log.info "FlowPass1Output::dbLoad rulesFlows #{@dbhost}/#{@dbname}"
							@rulesFlows = FLOW_RULES.new(@dbhost, @dbname, @dbuser, @dbpass)
						end
					rescue StandardError => e  
						log.error "FlowPass1Output::dbLoad error - #{e.message}"
						# puts e.backtrace.inspect 
						@rules = nil
					end
					
				end 


				def setDBdate(rtimestr)
					# dbClose 	# only if using SQLite
					@yyyymmdd = rtimestr
					sqlCREATE()
					# dbOpen 	# only if using SQLite
				end

				def handle_record(tag, time, record)
					# time is  Fluent::EventTime	https://www.rubydoc.info/gems/fluentd/Fluent/EventTime
					# http://stevenyue.com/blogs/date-time-datetime-in-ruby-and-rails/
					# log.warn "time is [#{time.inspect}]"
					# rtime = Date.strptime(time.to_s, "%Y-%m-%dT%H:%M:%S-04:00") # time.to_time
					rtime = Time.at(time.to_int)
					rtimestr = rtime.strftime("%Y%m%d")	# TODO: rename rtimestr to rtime_str
					rdate = rtimestr.to_i # TODO: rename rdate to rtime_i
					swapped = nil
					
					# rdate = rtimestr = 'individual' # temporary fix
					if @yyyymmdd != rtimestr
						setDBdate rtimestr
					end
					
					if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
						#match_type = "unknown"
						
						# a)Rules
						if @rulesFlows.nil?
							ruleName = nil
						else
							ruleName = @rulesFlows.match(record["flow"])
							if ruleName.nil?
								if swapped.nil?
									swapped = createSwapped(record["flow"]) 
								end
								ruleName = @rulesFlows.match(swapped)
							else
							end
						end
						if !ruleName.nil?
							match_type = "rule"
							record["flow"]["match_type"] = match_type
							record["flow"]["match_key"] = ruleName
							insertUpdateDetail(time, rdate, record["flow"], match_type, swapped, @saveRulesDetail)
							return
						end
						
						# b)Combined Flows
						if @rulesCombinedFlows.nil?
							ruleName = nil
						else
							ruleName = @rulesCombinedFlows.match(record["flow"])
							if ruleName.nil?
								if swapped.nil?
									swapped = createSwapped(record["flow"]) 
								end
								ruleName = @rulesCombinedFlows.match(swapped)
							end
						end
						if !ruleName.nil?				
							match_type = "combined"
							record["flow"]["match_type"] = match_type
							record["flow"]["match_key"] = ruleName
							insertUpdateDetail(time, rdate, record["flow"], match_type, swapped, @saveRulesDetail)
							return
						end
						
						# c)individual d)unknown
						match_type = "unknown"

						if record["flow"]["serviceDirection"] == "src"
							record["flow"]["dst"]["port"] = 0
							match_type = "individual"
						elsif record["flow"]["serviceDirection"] == "dst"
							record["flow"]["src"]["port"] = 0
							match_type = "individual"
						else
							match_type = "unknown"
						end
						
						record["flow"]["match_type"] = match_type
						# record["flow"]["match_key"] = ruleName
						insertUpdateDetail(time, rdate, record["flow"], match_type, swapped, nil)
					else
						log.error "FlowPass1Output:handle_record() Database not open"
					end
				end # def handle_record
				
				
		def insertUpdateDetail(time, rdate, flow, match_type, swapped, bSaveDetail)
				hits = sqlExists_Individual(flow, rdate, bSaveDetail)
				# TODO : forward and reverse
				if hits <= 0
					# is it reversed?
					# 
					if swapped.nil?
						swapped = createSwapped(flow) 
					end
					hitsSwapped = sqlExists_Individual(swapped, rdate, bSaveDetail)
				end
				
				if hits > 0
					sqlUPDATE_Individual(flow, time, hits, rdate, bSaveDetail)
				else
					if hitsSwapped > 0 
						sqlUPDATE_Individual(swapped, time, hitsSwapped, rdate, bSaveDetail)
					else
						sqlINSERT_Individual(flow, time, rdate, match_type, bSaveDetail)
					end
				end				
		end # 
				

	def createSwapped(flow) 
		swapped = flow.clone
		swapped["src"] = flow["dst"].clone
		swapped["dst"] = flow["src"].clone
		swapped["in_bytes"] = flow["out_bytes"] #.clone
		swapped["out_bytes"] = flow["in_bytes"] # .clone
		return swapped
	end # def createSwapped

	def sqlCREATE() # override
#		log.debug "FlowPass1Output:sqlCREATE(#{@yyyymmdd}) step 1"
		if !@dates.key?(@yyyymmdd) 
#		log.debug "FlowPass1Output:sqlCREATE(#{@yyyymmdd}) step 2"
		begin
			if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)			
#				log.debug "FlowPass1Output:sqlCREATE(#{@yyyymmdd}) drop table"
#				@db.exec ("DROP TABLE flow_detail_#{@yyyymmdd};")
				rows = @db.exec <<-SQL 
						
						CREATE TABLE IF NOT EXISTS flow_detail_#{@yyyymmdd} 
						(
							srcip varchar(200),
							dstip varchar(200),
							proto varchar(200),
							srcport int,
							dstport int,
				
							servicename varchar(200),
							srcnetwork varchar(200),
							dstnetwork varchar(200),
							srcnetblock varchar(200),
							dstnetblock varchar(200),
							srcdns varchar(200),
							dstdns varchar(200),
				
							match_type varchar(200),
							match_key varchar(200),

							hits int,
							bytes_in bigint,
							bytes_out bigint,
							json_data JSONB,
				
							PRIMARY KEY (srcip, dstip, proto, srcport, dstport)

						) INHERITS (timestamp_object);

						DROP TRIGGER IF EXISTS update_flow_detail_#{@yyyymmdd}_changetimestamp
							ON public.flow_detail_#{@yyyymmdd};

						CREATE TRIGGER update_flow_detail_#{@yyyymmdd}_changetimestamp BEFORE UPDATE
							ON flow_detail_#{@yyyymmdd} FOR EACH ROW EXECUTE PROCEDURE 
							update_changelast_modified_column();

					SQL
			end # if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)	
		rescue PG::Error => err
			log.error PG_Error_to_s(err)		
		end
		@dates[@yyyymmdd] = @yyyymmdd
	  end
	end # sqlCREATE
	
	def sqlINSERT_Individual(flow, time, rdate, match_type, bSaveDetail)
		if @yyyymmdd != rdate
			setDBdate rdate
		end

		if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
	#		@@logger.debug "SQL.INSERT #{flow.inspect}"
			srcdns = flow["src"]["dns"].nil? ? "" : flow["src"]["dns"]
			dstdns = flow["dst"]["dns"].nil? ? "" : flow["dst"]["dns"]
			srcnetwork = flow["src"]["network"].nil? ? "" : flow["src"]["network"]
			dstnetwork = flow["dst"]["network"].nil? ? "" : flow["dst"]["network"]
			srcnetblock = flow["src"]["netblock"].nil? ? "" : flow["src"]["netblock"]['name']
			dstnetblock = flow["dst"]["netblock"].nil? ? "" : flow["dst"]["netblock"]['name']
			servicename = flow["serviceName"].nil? ? "" : flow["serviceName"]
#			match_key = flow['match_key'].nil? ? '#{flow["src"]["ip"].to_s}:#{flow["src"]["port"]}/#{flow["protocol_name"]}/#{flow["dst"]["ip"].to_s}:#{flow["dst"]["port"]}' : flow['match_key']
			match_key = flow['match_key'].nil? ? "#{flow['src']['ip'].to_s}:#{flow['src']['port']}/#{flow['protocol_name']}/#{flow['dst']['ip'].to_s}:#{flow['dst']['port']} ": flow['match_key']


			if flow["bytes"].nil? || flow["bytes"] == ""
				bytes_in = bytes_out = 0
			else
				bytes = flow["bytes"].to_i
				bytes_in = flow["in_bytes"].to_i
				bytes_out = flow["out_bytes"].to_i
			end
			hits = 1
			
			begin
				flowstr = flow.to_json.to_s
			rescue => err
				log.error "FlowPass1Output:sqlINSERT() Exception converting flow [#{err}]"
				flowstr = nil
			end
			
			if flowstr.nil?
				begin
					flowstr = flow.to_s.force_encoding('ISO-8859-1')
				rescue => err
					log.error "FlowPass1Output:sqlINSERT() Exception(2) converting flow [#{err}]"
					flowstr = "{}"
				end
			end
		
			queryParams = [flow["src"]["ip"].to_s, flow["dst"]["ip"].to_s, flow["protocol_name"], flow["src"]["port"].to_i, flow["dst"]["port"].to_i, srcdns, dstdns, srcnetwork, dstnetwork, srcnetblock, dstnetblock, servicename, match_type, match_key, bytes_in, bytes_out, hits, flowstr]

			if !bSaveDetail.nil?
				if !bSaveDetail 
					if flow.key?("match_key")
						queryParams = [flow["match_key"].to_s, flow["match_key"].to_s, flow["match_key"].to_s, 0, 0, '', '', '', '', '', '', '', match_type, match_key, bytes_in, bytes_out, hits, '{}']
					end
				end
			end

	# puts "sqlINSERT match=[#{match}]"
			rows = @db.exec_params("INSERT INTO flow_detail_#{rdate}  (srcip, dstip, proto, srcport, dstport, srcdns, dstdns, srcnetwork, dstnetwork, srcnetblock, dstnetblock, servicename, match_type, match_key, bytes_in, bytes_out, hits, json_data) VALUES($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)", 
				queryParams)
		else
			log.error "FlowPass1Output:sqlINSERT() Database not open"
		end
	end #def

	def sqlUPDATE_Individual(flow, time, hits, rdate, bSaveDetail)
		if @yyyymmdd != rdate
			setDBdate rdate
		end
		if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
			if flow["bytes"].nil? || flow["bytes"] == ""
				bytes = 0
				bytes_in = 0
				bytes_out = 0
			else
				bytes = flow["bytes"].to_i
				bytes_in = flow["in_bytes"].to_i
				bytes_out = flow["out_bytes"].to_i
			end
			old_bytes_in, old_bytes_out, hits = sqlBytes_Individual(flow, rdate, bSaveDetail)
			queryParams = [hits + 1, bytes_in + old_bytes_in, bytes_out + old_bytes_out, flow["src"]["ip"].to_s, flow["dst"]["ip"].to_s, flow["protocol_name"], flow["src"]["port"].to_i, flow["dst"]["port"].to_i]
			if !bSaveDetail.nil?
				if !bSaveDetail 
					if flow.key?("match_key")
						queryParams = [hits + 1, bytes_in + old_bytes_in, bytes_out + old_bytes_out, flow["match_key"].to_s, flow["match_key"].to_s, flow["match_key"].to_s, 0, 0]
					end
				end
			end
			# newbytes = bytes + 
			rows = @db.exec_params("UPDATE flow_detail_#{rdate} SET hits = $1, bytes_in = $2, bytes_out = $3 WHERE srcip = $4 AND dstip = $5 AND proto = $6 AND srcport = $7 AND dstport = $8  ", # dateAdded = $1, dateLastSeen = $2, AND srcdomain = $10 AND dstdomain = $11
				queryParams)	# , srcdomain, dstdomain
		else
			log.error "FlowPass1Output:sqlUPDATE() Database not open"
		end
	end #def
	
	def sqlExists_Individual(flow, rdate, bSaveDetail)
		if @yyyymmdd != rdate
			setDBdate rdate
		end
		if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
			# srcdomain = flow["src"]["domain"].nil? ? "" : flow["src"]["domain"].to_s
			# dstdomain = flow["dst"]["domain"].nil? ? "" : flow["dst"]["domain"].to_s
			queryParams =[flow["src"]["ip"].to_s, flow["dst"]["ip"].to_s, flow["protocol_name"].to_s, flow["src"]["port"].to_i, flow["dst"]["port"].to_i]
			if !bSaveDetail.nil?
				if !bSaveDetail 
					if flow.key?("match_key")
						queryParams =[flow["match_key"].to_s, flow["match_key"].to_s, flow["match_key"].to_s, 0, 0]
					end
				end
			end
			results = @db.exec_params("SELECT sum(hits) as sumhits FROM flow_detail_#{rdate} WHERE srcip = $1 AND dstip = $2 AND proto = $3 AND srcport = $4 AND dstport = $5 ", #AND srcdomain = $6 AND dstdomain = $7
				queryParams) # , srcdomain, dstdomain
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
			log.error "FlowPass1Output:sqlExists() Database not open"
		end
		return 0
	end #def

	# TODO: private???
	def sqlBytes_Individual(flow, rdate, bSaveDetail)
		if @yyyymmdd != rdate
			setDBdate rdate
		end
		if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
#			srcdomain = flow["src"]["domain"].nil? ? "" : flow["src"]["domain"]
#			dstdomain = flow["dst"]["domain"].nil? ? "" : flow["dst"]["domain"]
			queryParams = [flow["src"]["ip"].to_s, flow["dst"]["ip"].to_s, flow["protocol_name"], flow["src"]["port"].to_i, flow["dst"]["port"].to_i]
			if !bSaveDetail.nil?
				if !bSaveDetail 
					if flow.key?("match_key")
						queryParams =[flow["match_key"].to_s, flow["match_key"].to_s, flow["match_key"].to_s, 0, 0]
					end
				end
			end

			results = @db.exec_params("SELECT bytes_in, bytes_out, hits FROM flow_detail_#{rdate} WHERE srcip = $1 AND dstip = $2 AND proto = $3 AND srcport = $4 AND dstport = $5", #  AND srcdomain = $6 AND dstdomain = $7 
				queryParams) # , srcdomain, dstdomain
			rows = results.values

			if rows.nil?
				return [0,0,0]
			end
			if rows.length == 0 
				return [0,0,0]
			end
			row = rows[0]
			if row[0].nil? || row[0] == ""
				return [0,0,0]
			end
	#puts "sqlBytes rows #{rows} row  #{row}" 	
	#puts "sqlBytes row['bytes']  #{row['bytes']}" 	
	#		return row['bytes'].to_i
			return [row[0].to_i, row[1].to_i, row[2].to_i]
		else
			log.error "FlowPass1Output:sqlBytes() Database not open"
		end	
		return 0
	end # def
    end # class
    
  end # module
end # module