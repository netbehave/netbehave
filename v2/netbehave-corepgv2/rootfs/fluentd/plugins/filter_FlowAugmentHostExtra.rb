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
    class FlowAugmentHostExtraFilter < Fluent::Plugin::Filter
    	include PgClasses # mixin used since multiple inheritance is not possible in Ruby
    	
        Fluent::Plugin.register_filter('FlowAugmentHostExtra', self)

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
				 if !record["flow"]["src"]["host"].nil?
					 augmentWithHostExtra(record["flow"]["src"])
				 end
			 
				 if !record["flow"]["dst"]["host"].nil?
					 augmentWithHostExtra(record["flow"]["dst"])
				 end
			 end			

			record
		end

                
        private

=begin

CREATE TABLE IF NOT EXISTS host_info_extra (
  id_host_info 	INT, 
  host_source		TEXT,
  host_source_id	TEXT,

  category			TEXT,
  optkey			TEXT,
  json_data 		JSONB,

  FOREIGN KEY (id_host_info) REFERENCES host_info (id_host_info)
) INHERITS (timestamp_object);



=end

		def augmentWithHostExtra(frecord)
				begin
					# ip_i = IPAddr.new(ip, Socket::AF_INET).to_i

					if !dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
						return
					end

					rows = nil
					if frecord["host"].nil?
						# does not exist, do nothing
					else
						if frecord["host"]['id_host_info'].nil?
							# exists 
							rows = @db.exec_params("SELECT category, optkey, json_data FROM host_info_extra WHERE id_host_info = $1 AND host_source = $2 AND host_source_id = $3;", [host["id_host_info"], host["source"], host["source_id"]  ])
						else
						# does not exist, do nothing
						end
					end 


					if rows.nil?
						return 
					end
					
					rows.each do |row|
						category = {}
						category["name"] 		= row['category']
						category["key"]  		= row['optkey']
						category["data"] 	= JSON.parse(row['json_data'])
						frecord["host"][category["name"]] = category
					end

				rescue => e
				end
				
		end

		# overwrite

				
		end # class
    end #  module Plugin
end # module Fluent
 

