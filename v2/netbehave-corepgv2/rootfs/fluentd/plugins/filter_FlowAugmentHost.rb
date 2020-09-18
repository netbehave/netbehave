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
require "fluent/plugin/filter"
require "json"
require 'ipaddr'
require 'net/http'
require 'pg'

require_relative 'pg_classes' # .rb

module Fluent
  module Plugin
    class FlowAugmentHostFilter < Fluent::Plugin::Filter
    	include PgClasses # mixin used since multiple inheritance is not possible in Ruby
    	
        Fluent::Plugin.register_filter('FlowAugmentHost', self)

#		config_param :dbfile, :string, :default => nil
		config_param :onlyNoDomains, :bool, :default => false # TODO
		config_param :dbhost, :string,  default: 'localhost'
		config_param :dbname, :string,  default: 'postgres'
		config_param :dbuser, :string,  default: 'postgres'
		config_param :dbpass, :string,  default: 'postgres'

		def configure(conf)
			super
		end
		
		def start
			super
			# dbOpen
		end

		def shutdown
			super
			# dbClose
		end		

		def filter(tag, time, record)					
			# log.info "FlowArinWhoisFilter: #{record["flow"].inspect}"
			 if !record["flow"].nil?
				 if !record["flow"]["src"]["ip"].nil?
					 augmentWithHost(record["flow"]["src"]["ip"], record["flow"]["src"])
				 end
			 
				 if !record["flow"]["dst"]["ip"].nil?
					 augmentWithHost(record["flow"]["dst"]["ip"], record["flow"]["dst"])
				 end
			 end			

			record
		end

                
        private

=begin

CREATE TABLE host_info (
  id_host_info SERIAL PRIMARY KEY, 
  host_source		TEXT,
  host_source_id	TEXT,
  name				TEXT,
  json_data 		JSONB,
  UNIQUE (host_source, host_source_id)
) INHERITS (timestamp_object);



CREATE TABLE host_info_ip (
  id_host_info 	INT, 
  host_source		TEXT,
  host_source_id	TEXT,
  ip				TEXT,
  ip_i				BIGINT,
  intf				TEXT,
  netmask			TEXT,
  UNIQUE (host_source, host_source_id, ip)
) INHERITS (timestamp_object);


SELECT hip.id_host_info, hip.host_source, hip.host_source_id, hi.name FROM host_info_ip hip, host_info hi WHERE hi.id_host_info = hip.id_host_info AND hip.ip =

hi.json_data


=end

		def augmentWithHost(ip, frecord)
				begin
					# ip_i = IPAddr.new(ip, Socket::AF_INET).to_i

					if !dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
						return
					end

					if frecord["host"].nil?
						# not already identified host, use IP
						rows = @db.exec_params("SELECT hip.id_host_info, hip.host_source, hip.host_source_id, hi.name FROM host_info_ip hip, host_info hi WHERE hi.id_host_info = hip.id_host_info AND hip.ip = $1", [ip])
					else
						if frecord["host"]['id_host_info'].nil?
							# not already identified host, use IP
							rows = @db.exec_params("SELECT hip.id_host_info, hip.host_source, hip.host_source_id, hi.name FROM host_info_ip hip, host_info hi WHERE hi.id_host_info = hip.id_host_info AND hip.ip = $1", [ip])
						else
							# Host identified by id, grab straight from there
							rows = @db.exec_params("SELECT hi.id_host_info, hi.host_source, hi.host_source_id, hi.name FROM host_info hi WHERE hi.id_host_info = $1", [frecord["host"]['id_host_info']])
						end
					end 


					if rows.nil?
						return 
					end
					
					rows.each do |row|
						host = {}
						host["id_host_info"]= row['id_host_info']
						host["source"] 		= row['host_source']
						host["source_id"] 	= row['host_source_id']
						host["name"] 		= row['name']
							# json?
						frecord["host"] = host
					end

					if frecord["host"].nil?						
						# needed ??

						begin
						# log.info "SELECT json_data FROM unknown WHERE unknown_type = 'dns' AND unknown_key = '#{ip}';"						
							rows = @db.exec_params("SELECT json_data FROM unknown WHERE unknown_type = $1 AND unknown_key = $2;", ['host_info_ip', ip])
						rescue PG::Error => err
							log.error PG_Error_to_s(err)
							rows = nil
						end

						if rows.nil? || rows.ntuples == 0
							# log.info "INSERT INTO unknown (unknown_type, unknown_key, json_data) VALUES ('dns', #{ip}', '#{jso.to_json.to_s}'); ';"						
							jso = {}
							jso = frecord
							rows = @db.exec_params("INSERT INTO unknown (unknown_type, unknown_key, json_data, status) VALUES ('host_info_ip', $1, $2, 'new');", [ip, jso.to_json.to_s])
						else
							# rows = @db.exec_params("UPDATE unknown SET json_data = $1 WHERE unknown_type = $2 AND unknown_key = $3", [jso.to_s, 'dns', ip])
						end

					end # if frecord["host"].nil?	
				rescue => e
				end
				
		end

		# overwrite

				
		end # class
    end #  module Plugin
end # module Fluent
 

