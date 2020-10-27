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
# require "json"
# require 'pg'
require_relative 'pg_classes' # .rb


module Fluent
  module Plugin
    class FlowAugmentServiceFilter < Fluent::Plugin::Filter
    	include PgClasses # mixin used since multiple inheritance is not possible in Ruby
      Fluent::Plugin.register_filter("FlowAugmentService", self)

#		config_param :strict, :bool, :default => false
		config_param :dbhost, :string,  default: 'localhost'
		config_param :dbname, :string,  default: 'postgres'
		config_param :dbuser, :string,  default: 'postgres'
		config_param :dbpass, :string,  default: 'postgres'

	def configure(conf)
		super
		log.info "FlowAugmentService:configure() connection=#{dbuser}@#{dbhost}/#{dbname})"
		@lookup_table = {}
		@lookup_table = create_lookup_table()
	end

		def filter(tag, time, record)
			if @lookup_table.size == 0
				@lookup_table = create_lookup_table()
				log.info "FlowAugmentService:configure #{@lookup_table.size} services loaded"
			end
			
			if !record.key?("flow")
				record
			end
			flow = record["flow"]
			
			 if flow["protocol_name"] == "TCP" || flow["protocol_name"] == "UDP"
				srckey = "#flow["src"]["port"]}/#{flow["protocol_name"].downcase}"
				dstkey = "#flow["dst"]["port"]}/#{flow["protocol_name"].downcase}"


				augmentWithIpListen(flow["dst"]["ip"], flow["protocol_name"], flow["dst"]["port"], flow, "dst")
				if flow["serviceDirection"].nil?
					augmentWithIpListen(flow["src"]["ip"], flow["protocol_name"], flow["src"]["port"], flow, "src")
				end


				if flow["serviceDirection"].nil?
					if @lookup_table.key?(dstkey)
						flow["serviceName"] = @lookup_table[dstkey]["serviceName"]
						flow["serviceDescription"] = @lookup_table[dstkey]["serviceDescription"]
						flow["serviceDirection"] = "dst"
					elsif @lookup_table.key?(srckey)
						flow["serviceName"] = @lookup_table[srckey]["serviceName"]
						flow["serviceDescription"] = @lookup_table[srckey]["serviceDescription"]
						flow["serviceDirection"] = "src"
					else
						# No service direction
						# Do we want to save it in unknown? 
					end
				end

			 end
			record
		end # def filter

	private

		# overwrite
		def sqlCREATE
			# nothing to do
		end

=begin
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
		def augmentWithIpListen(ip, protocol, port, frecord, srcdst)
				begin
					if !dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
						return
					end

					rows = @db.exec_params("SELECT service_name, id_host_info, json_data FROM ip_listen WHERE ip = $1 AND protocol = $2 AND port = $3", [ip, protocol, port])
					if rows.nil?
						return 
					end

					rs.each do |row|
						# frecord["serviceName"] = netblock
						
						frecord["serviceName"] = row["service_name"]
						# record["flow"]["serviceDescription"] = @lookup_table[dstkey]["serviceDescription"]
						frecord["serviceDirection"] = srcdst
						frecord[srcdst]["listen"] = {}
						frecord[srcdst]["listen"]["id_host_info"] = row["id_host_info"]
						frecord[srcdst]["listen"]["data"] = row["json_data"]
						
					end

					if frecord["serviceName"].nil?
						# add netblock task
						# TODO
					end
				rescue => e
				end
				
		end
    
		def create_lookup_table()
			begin			
				lookup_table = {}
				if !dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
					return lookup_table
				end

				rs = @db.exec("SELECT protoPort, serviceName, serviceDescription FROM public.service;")
				
				rs.each do |row|
					handle_row(lookup_table, row)
				end
#				$log.info "FlowServicePGFilter::create_lookup_table #{@lookup_table.size} services"

				dbClose
				return lookup_table

			rescue StandardError => e  
				log.error "FlowAugmentService::create_lookup_table - #{e.message}"
				puts e.backtrace.inspect 

				return {}
			end # begin
		end # def create_lookup_table(file)

				
		def handle_row(lookup_table, row)
#				$log.info "FlowServicePGFilter::handle_row #{row}"
			lookup_table[row['protoport']] = {} 
			lookup_table[row['protoport']]["serviceName"] = row['servicename']
			lookup_table[row['protoport']]["serviceDescription"] = row['servicedescription']
		end # def handle_row(lookup_table, row)
				
		def handle_row_error(row, errmsg)
			log.error "FlowAugmentService row error ", row:row, error:errmsg 
		end # def handle_row_error(row, errmsg)
				
		def handle_file_err(file, err)
			log.error "FlowAugmentService file error ", file:file, error:err 
		end # def handle_file_err(file, err)

    end # class
  end
end

=begin
CREATE TABLE service
(
	protoPort text COLLATE pg_catalog."default" NOT NULL,
    serviceName text COLLATE pg_catalog."default" NOT NULL,
    serviceDescription text COLLATE pg_catalog."default" NOT NULL,
	PRIMARY KEY (protoPort, serviceName, serviceDescription)

)
=end