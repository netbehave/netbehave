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
    class FlowAugmentNetBlockFilter < Fluent::Plugin::Filter
    	include PgClasses # mixin used since multiple inheritance is not possible in Ruby
    	
        Fluent::Plugin.register_filter('FlowAugmentNetBlock', self)

		config_param :dbfile, :string, :default => nil
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
					 augmentWithNetblock(record["flow"]["src"]["ip"], record["flow"]["src"])
				 end
			 
				 if !record["flow"]["dst"]["ip"].nil?
					 augmentWithNetblock(record["flow"]["dst"]["ip"], record["flow"]["dst"])
				 end
			 end			

			record
		end

                
        private

=begin
CREATE TABLE net_block (
  ip_start_i		BIGINT,
  ip_end_i			BIGINT,
  ip_start			TEXT,
  ip_end			TEXT,
  net_block_source	TEXT,
  net_block_name	TEXT,
  net_block_mask	TEXT,
  net_block_subnet	TEXT,
  net_block_bits	INT,
  net_block_size	INT,
  json_data 		JSONB,
  PRIMARY KEY (ip_start_i, ip_end_i)
) INHERITS (timestamp_object);

CREATE TABLE unknown (
  unknown_type	TEXT,
  unknown_key	TEXT,
  json_data 		JSONB,
  PRIMARY KEY (unknown_type, unknown_key)
) INHERITS (timestamp_object);


CREATE TRIGGER update_unknown_changetimestamp BEFORE UPDATE
    ON unknown FOR EACH ROW EXECUTE PROCEDURE 
    update_changelast_modified_column();


SELECT net_block_name, net_block_source, net_block_subnet FROM net_block WHERE ip_start_i <= 3232235550 AND ip_end_i >= 3232235550
SELECT json_data FROM unknown WHERE unknown_type = 'net_block' AND unknown_key = '161.69.17.0/24'
=end

		def augmentWithNetblock(ip, frecord)
				begin
					ip_i = IPAddr.new(ip, Socket::AF_INET).to_i

					if !dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
						return
					end

					rows = @db.exec_params("SELECT net_block_name, net_block_source, net_block_subnet FROM net_block WHERE ip_start_i <= $1 AND ip_end_i >= $2;", [ip_i, ip_i])
					if !rows.nil?
						rows.each do |row|
#						log.info "Netblock for ip=#{ip},#{ip_i	} => [#{row[0]},#{row[1]},#{row[2]}] #{row.to_s}"
							netblock = {}
							netblock["name"] 	= row['net_block_name']
							netblock["source"] 	= row['net_block_source']
							netblock["subnet"] 	= row['net_block_subnet']
							frecord["netblock"] = netblock
						end
#						rows.close						
					end

#					if !dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
#						return
#					end


					if frecord["netblock"].nil?						
						# add netblock task
						subnet24 = IPAddr.new(ip, Socket::AF_INET).mask(24)
#						log.info "No Netblock for ip=#{ip},#{ip_i} in subnet #{subnet24}/24"		
#						log.info "SELECT json_data FROM unknown WHERE unknown_type = 'net_block' AND unknown_key = '#{subnet24}/24'"
						
						begin
							rows = @db.exec_params("SELECT json_data FROM unknown WHERE unknown_type = $1 AND unknown_key = $2;", ['net_block', "#{subnet24}/24"])
						rescue PG::Error => err
							log.error PG_Error_to_s(err)		
						end
						
#						log.info "after @db.exec_params"
						if rows.nil? || rows.ntuples == 0
#							log.info "Unknown-INSERT Netblock for ip=#{ip},#{ip_i} in subnet #{subnet24}"		
							jso = {}
							jso["ip"] = []
							# jso["ip"][0] = ip
							jso["ip"].push(ip)
#							log.info "INSERT INTO unknown (unknown_type, unknown_key, json_data) VALUES ('net_block', '#{subnet24}/24', '#{jso.to_json.to_s}');"
						begin
							rows = @db.exec_params("INSERT INTO unknown (unknown_type, unknown_key, json_data, status) VALUES ('net_block', $1, $2, 'new');", ["#{subnet24}/24", jso.to_json.to_s])
						rescue PG::Error => err
							log.error PG_Error_to_s(err)		
						end
#						log.info "after @db.exec_params"
						else
							rows.each do |row|
								jso = JSON.parse(row['json_data'])
							end
							if !jso["ip"].include?(ip)
								jso["ip"] |= [ip]  # jso["ip"].push(ip)							
#								log.info "Unknown-UPDATE Netblock for ip=#{ip},#{ip_i} in subnet #{subnet24} #{jso.to_json.to_s}"		
								rows = @db.exec_params("UPDATE unknown SET json_data = $1 WHERE unknown_type = $2 AND unknown_key = $3;", [jso.to_json.to_s, 'net_block', "#{subnet24}/24"])
							end							
						end
						
					end
				rescue => e
				end
				
		end

		# overwrite

				
		end # class
    end #  module Plugin
end # module Fluent
 

