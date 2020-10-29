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
  
class FLOW_CATEGORIES < PG_ACL

	def create_lookup_table_from_db()
		rs = @db.exec("SELECT cat, subcat, rulecsv, id_flow_categories as id FROM flow_categories")
		rs.each do |row|
			begin
	      		parse_row_db(row)
	      	rescue => err
	      		$log.error "FLOW_CATEGORIES:create_lookup_table_from_db() Error: #{err.to_s}"
	      	end		
		end
		$log.info "FLOW_CATEGORIES:create_lookup_table_from_db::Loaded #{@nbRules} rules"
	end
	
	def parse_row_db(row)
		aclName = row['match_key']
		
		fields = []
		if !row['srcips'].nil? && row['srcips'].length > 0
			fields.push( AclField.new("src/ip=#{row['srcips']}") )
		end
		fields.push( AclField.new("dst/ip=#{row['dstips']}") )
		fields.push( AclField.new("protocol_name=#{row['protos']}") )
		if !row['srcports'].nil? && row['srcports'].length > 0
			fields.push( AclField.new("src/port=#{row['srcports']}") )
		end
		fields.push( AclField.new("dst/port=#{row['dstports']}") )
		
		@rules[@nbRules]  = {}
		@rules[@nbRules]["id"] = row['id']
		@rules[@nbRules]["cat"] = row['cat']
		@rules[@nbRules]["subcat"] = row['subcat']
		@rules[@nbRules]["name"] = "#{row['cat']};#{row['subcat']}"
		
		rowcsv = row['rulecsv'].split(',')
		fields = []
		(0..rowcsv.length-1).each do |col|
			fields[col] = AclField.new(rowcsv[col])
		end
		@rules[@nbRules]["fields"] = fields
		
		@nbRules = @nbRules + 1
	end



	def match(flow)
		dbLoad
		@rules.each { | rule |
			if MatchRule(rule, flow)
				return "#{rule["id"]};#{rule["name"]}"
			end
		}
		return nil
	end

end # class CombinedFlows  
  
    class FlowCategorizeOutput < Fluent::Plugin::Output
    	include PgClasses # mixin used since multiple inheritance is not possible in Ruby
    	# includes: dbOpen, dbClose
		      Fluent::Plugin.register_output("FlowCategorize", self) 

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
					@rulesCategories = nil
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
						if @rulesCategories.nil?
							log.info "FlowCategorizeOutput::dbLoad rulesFlows #{@dbhost}/#{@dbname}"
							@rulesFlows = FLOW_CATEGORIES.new(@dbhost, @dbname, @dbuser, @dbpass)
						end
					rescue StandardError => e  
						log.error "FlowCategorizeOutput::dbLoad error - #{e.message}"
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
						if @rulesCategories.nil?
							ruleName = nil
						else
							ruleName = @rulesCategories.match(record["flow"])
							if ruleName.nil?
								if swapped.nil?
									swapped = createSwapped(record["flow"]) 
								end
								ruleName = @rulesCategories.match(swapped)
							else
							end
						end
						if !ruleName.nil?
							match_type = "rule"
							record["flow"]["match_type"] = "category"
							record["flow"]["match_key"] = ruleName
							if swapped.nil?
								insertUpdateDetail(time, rdate, record["flow"], "category", ruleName)
							else
								insertUpdateDetail(time, rdate, swapped, "category", ruleName)
							end
							return
						end
						
					else
						log.error "FlowCategorizeOutput:handle_record() Database not open"
					end
				end # def handle_record
				
		def createSwapped(flow) 
			swapped = flow.clone
			swapped["src"] = flow["dst"].clone
			swapped["dst"] = flow["src"].clone
			swapped["in_bytes"] = flow["out_bytes"] #.clone
			swapped["out_bytes"] = flow["in_bytes"] # .clone
			return swapped
		end # def createSwapped

		def sqlCREATE() # override
			# do nothing here
		end # sqlCREATE
				
		def insertUpdateDetail(time, rdate, flow, match_type, match_key)
			if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
				id_flow_categories, cat, subcat =  match_key.split(";") 
				srcidhost= flow["src"]["host"].nil? ? "" : flow["src"]["host"]['id_host_info']
				dstidhost = flow["dst"]["host"].nil? ? "" : flow["dst"]["host"]['id_host_info']
				jso = {}			
				# flow_summary
				queryParams = [flow["src"]["ip"].to_s, flow["dst"]["ip"].to_s, cat, subcat, id_flow_categories, srcidhost, dstidhost, jso.to_json.to_s]
				rows = @db.exec_params("INSERT INTO flow_summary (srcip, dstip, cat, subcat, id_flow_categories,  src_id_host_info, dst_id_host_info, json_data) VALUES($1, $2, $3, $4, $5, $6, $7, $8) ON CONFLICT DO NOTHING;", 
					queryParams)
					
				if flow["bytes"].nil? || flow["bytes"] == ""
					bytes_in = bytes_out = 0
				else
					bytes = flow["bytes"].to_i
					bytes_in = flow["in_bytes"].to_i
					bytes_out = flow["out_bytes"].to_i
				end
				hits = 1
					
				# flow_summary_daily
				queryParams = [flow["src"]["ip"].to_s, flow["dst"]["ip"].to_s, cat, subcat, rdate, id_flow_categories, srcidhost, dstidhost, bytes_in, bytes_out, hits, jso.to_json.to_s]
				rows = @db.exec_params("INSERT INTO flow_summary_daily (srcip, dstip, cat, subcat, datestr, id_flow_categories,  src_id_host_info, dst_id_host_info, bytes_in, bytes_out, hits, json_data) VALUES($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) ON CONFLICT DO UPDATE SET hits = EXCLUDED.hits + flow_summary_daily.hits, bytes_in = EXCLUDED.bytes_in + flow_summary_daily.bytes_in, bytes_out = EXCLUDED.bytes_out + flow_summary_daily.bytes_out;", queryParams)
			else
				log.error "FlowCategorizeOutput:insertUpdateDetail() Database not open"
			end # if dbOpen
		
		end # 
				


    end # class
    
  end # module
end # module