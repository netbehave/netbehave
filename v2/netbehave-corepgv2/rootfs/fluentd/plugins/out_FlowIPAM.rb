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
require "socket"
require 'pg'

require_relative 'pg_classes' # .rb

# TODO: cache ttl
# TODO: storage

module Fluent
  module Plugin
    class FlowIpamOutput < Fluent::Plugin::Output
    	include PgClasses # mixin used since multiple inheritance is not possible in Ruby

      Fluent::Plugin.register_output("FlowIPAM", self)

    			config_param :local_network_name, :string, default: nil
    			config_param :outlabel, :string, :default => nil
			    config_param :secondsInactive, :integer, default: 300 # 300 sec = 5min
    			config_param :dbhost, :string,  default: 'localhost'
    			config_param :dbname, :string,  default: 'postgres'
    			config_param :dbuser, :string,  default: 'postgres'
    			config_param :dbpass, :string,  default: 'postgres'
    			config_param :newIPfile, :string,  default: nil
    
                def configure(conf)
					super
#			log.debug "FlowIpamOutput::configure"
					@localIPs = {}
					@destLabel = ""
					if (@destLabel.nil? || @destLabel.empty?)
						if outlabel.nil?
							# no else tag
							else
								@destLabel = outlabel
							end
					end
                end
                def start
                    super
#			log.debug "FlowIpamOutput::start"
                end
                def shutdown
                    super
                    dbClose
#					@localIPs.each_pair { |key, value|
#						log.info "FlowAsset", asset:value
#					}                       
                end

				def emit(tag, es, chain)
#		$log.debug "FlowIpamPgOutput.emit "
					es.each do |time, record|
						handle_record(tag, time, record)
					end
					chain.next
				end # def emit

				def process(tag, es)
#		$log.debug "FlowIpamPgOutput.process "
					es.each do |time, record|
						handle_record(tag, time, record)
					end
				end # def process

			private

				def handle_record(tag, time, record)
					label = Engine.root_agent.find_label(@destLabel)
					router = label.event_router

					flow = record["flow"]

					if !flow["bytes"].nil?
						bytes = flow["bytes"]
					else
						bytes = 0
					end

#			log.debug "FlowIpamPgOutput::handle_record(#{flow.to_json})"

					if flow["src"]["network"] == @local_network_name
						handle_ip(tag, time, flow["src"], bytes)

					end

					if flow["dst"]["network"] == @local_network_name
						handle_ip(tag, time, flow["dst"], bytes)

					end

				end # def handle_record
    
    			def handle_ip(tag, time, flowSrcDst, bytes)
					label = Engine.root_agent.find_label(@destLabel)
					router = label.event_router

						ip = flowSrcDst["ip"].to_s
						mac = flowSrcDst["mac"].to_s
#			log.debug "FlowIpamPgOutput::handle_ip(#{ip},[#{mac}]"
						if @localIPs.key?(ip)
							# Existing IP in local list
							diff = time.to_i - @localIPs[ip]["lastSeen"]
							@localIPs[ip]["lastSeen"] = time.to_i
							@localIPs[ip]["bytes"] = @localIPs[ip]["bytes"]  + bytes
							if diff > @secondsInactive 
								frecord = {}
								frecord["asset"] = @localIPs[ip]
								frecord["action"] = "update"
								frecord["type"] = "flow"
								frecord["time"] = time.to_i
								router.emit(tag, time, frecord) 
								sqlUPDATE(frecord["asset"])
							end
						else
							@localIPs[ip] = {}
							@localIPs[ip]["ip"] = ip
							@localIPs[ip]["mac"] = mac
							@localIPs[ip]["firstSeen"] = time.to_i
							@localIPs[ip]["lastSeen"] = time.to_i
							@localIPs[ip]["bytes"] = bytes
							frecord = {}
							frecord["asset"] = @localIPs[ip]
#							frecord["action"] = "new"
							frecord["type"] = "flow"
							frecord["time"] = time.to_i

							# IP not present in local list, but could exist in DB
							if sqlExistOrCreate(ip) > 0
								#already exists
								frecord["action"] = "update"
								sqlUPDATE(frecord["asset"])
							else
								sqlINSERT(frecord["asset"])
								frecord["action"] = "new"
							end

							router.emit(tag, time, frecord) 
						end
    			end 


	def outToFileNew(ipa)
		# TODO
		if !@newIPfile.nil?
#			log.info "FlowIpamPgOutput::outToFileNew(#{@newIPfile})[#{ipa.to_json}]"
			appendToFile(@newIPfile, "#{ipa.to_json}\n")		
		end
	end
	
	def appendToFile(filename, txt)
		open(filename, 'a') { |f|
			f << txt
			f.close
		} # open file
	end # def appendToFile


=begin
CREATE TABLE ip (
  ip				TEXT	PRIMARY KEY ,
  ip_i				BIGINT NOT NULL,
  ip_version	 	INT NOT NULL, 
  ip_version	 	INT NOT NULL,
  -- optional fields
  id_host_info 	INT,   
  net_block_source	TEXT,
  net_block_name	TEXT,
  json_data 		JSONB
) INHERITS (timestamp_object);



CREATE TABLE ip_listen (
  ip				TEXT NOT NULL,
  ip_i				BIGINT NOT NULL,
  protocol 			TEXT NOT NULL,
  port 				INT NOT NULL,
  ip_version	 	INT, 
  -- optional fields
  service_name 		TEXT,
  id_host_info 		INT,   
  json_data 		JSONB,
  PRIMARY KEY(ip, protocol, port)
) INHERITS (timestamp_object);
=end

	def sqlINSERT(ipa)
		if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
#			log.debug "SQL.INSERT #{ipa.to_json}"
			begin
				ip = IPAddr.new(ipa["ip"], Socket::AF_INET)
				ipver = ip.ipv4? ? 4 : 0
				rows = @db.exec_params("INSERT INTO ip (ip, ip_i, ip_version) VALUES($1, $2, $3)", [ipa["ip"], ip.to_i, ipver])

#todo: add net_block_source  net_block_name json_data
				outToFileNew(ipa)
			rescue => e
				log.debug "Error #{e}"
			end


		else
			log.debug "Database not opened"
		end
	end #def

	def sqlUPDATE(ipa)
		if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
#			log.debug "SQL.UPDATE #{ipa.to_json}"
# TODO
#			rows = @db.exec_params("UPDATE ip SET ip_version = ip_version WHERE ip = $1", [ipa["ip"]])
		else
			log.debug "Database not opened"
		end
	end #def

		# overwrite
	def sqlCREATE()
#			log.debug "FlowIpamPgOutput::sqlCREATE"
	end

	def sqlExistOrCreate(ip)
		if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
#			rows = @db.exec("SELECT ip, ip_i FROM ip WHERE ORDER BY ip ")
			rows = @db.exec_params("SELECT ip_i FROM ip WHERE ip = $1", [ip])
			return rows.num_tuples
		else
			log.debug "Database not opened"
			return 0
		end
	end


    end #class
  end # module
end # module