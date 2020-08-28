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
    class FlowAugmentDNSFilter < Fluent::Plugin::Filter
    	include PgClasses # mixin used since multiple inheritance is not possible in Ruby
    	
        Fluent::Plugin.register_filter('FlowAugmentDNS', self)

#		config_param :dbfile, :string, :default => nil
		config_param :onlyNoDomains, :bool, :default => false # TODO
		config_param :onlyNotExternal, :bool, :default => true # TODO
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
					 augmentWithDNS(record["flow"]["src"]["ip"], record["flow"]["src"])
				 end
			 
				 if !record["flow"]["dst"]["ip"].nil?
					 augmentWithDNS(record["flow"]["dst"]["ip"], record["flow"]["dst"])
				 end
			 end			

			record
		end

                
        private

=begin


CREATE TABLE dns_info (
  ip		TEXT,
  ip_i		BIGINT,
  name		TEXT,
  PRIMARY KEY (ip, ip_i, name)
) INHERITS (timestamp_object);


SELECT hip.id_host_info, hip.host_source, hip.host_source_id, hi.name FROM host_info_ip hip, host_info hi WHERE hi.id_host_info = hip.id_host_info AND hip.ip =

hi.json_data

"dst":{"ip":"192.168.0.30","port":63437,"mac":"28:f1:0e:04:f4:ae","network":"home",
"netblock":{"name":null,"source":null,"subnet":null},
"dns":null},

=end

def augmentWithDNS(ip, frecord)
	begin
		if !dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
			return
		end

		rows = @db.exec_params("SELECT name FROM dns_info WHERE ip = $1;", [ip])
		if !rows.nil?
			rows.each do |row|
				frecord["dns"] = row['name']
			end
		end

		if frecord["dns"].nil? 
			bDoAddUnknown = true
			if onlyNotExternal	&& frecord["network"] != "external" 
				bDoAddUnknown = false
			end
		if bDoAddUnknown 
			begin
			#						log.info "SELECT json_data FROM unknown WHERE unknown_type = 'dns' AND unknown_key = '#{ip}';"						
				rows = @db.exec_params("SELECT json_data FROM unknown WHERE unknown_type = $1 AND unknown_key = $2;", ['dns', ip])
			rescue PG::Error => err
				log.error PG_Error_to_s(err)		
			end

			if rows.nil? || rows.ntuples == 0
				jso = {}
				#						log.info "INSERT INTO unknown (unknown_type, unknown_key, json_data) VALUES ('dns', #{ip}', '#{jso.to_json.to_s}'); ';"						
				rows = @db.exec_params("INSERT INTO unknown (unknown_type, unknown_key, json_data, status) VALUES ('dns', $1, $2, 'new');", [ip, jso.to_json.to_s])
			else
				# rows = @db.exec_params("UPDATE unknown SET json_data = $1 WHERE unknown_type = $2 AND unknown_key = $3", [jso.to_s, 'dns', ip])
			end
		end 

		end # if frecord["dns"].nil? 
	rescue => e
	end

end

		# overwrite

				
		end # class
    end #  module Plugin
end # module Fluent
 

