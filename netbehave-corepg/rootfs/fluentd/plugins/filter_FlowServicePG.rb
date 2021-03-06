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
    class FlowServicePGFilter < Fluent::Plugin::Filter
    	include PgClasses # mixin used since multiple inheritance is not possible in Ruby
      Fluent::Plugin.register_filter("FlowServicePG", self)

		config_param :strict, :bool, :default => false
		config_param :dbhost, :string,  default: 'localhost'
		config_param :dbname, :string,  default: 'postgres'
		config_param :dbuser, :string,  default: 'postgres'
		config_param :dbpass, :string,  default: 'postgres'

	def configure(conf)
		super
		@lookup_table = {}
		@lookup_table = create_lookup_table()
	end

		def filter(tag, time, record)
			if @lookup_table.size == 0
				@lookup_table = create_lookup_table()
				log.info "FlowServicePGFilter:configure #{@lookup_table.size} services loaded"
			end
			
			 if record["flow"]["protocol_name"] == "TCP" || record["flow"]["protocol_name"] == "UDP"
				srckey = "#{record["flow"]["src"]["port"]}/#{record["flow"]["protocol_name"].downcase}"
				dstkey = "#{record["flow"]["dst"]["port"]}/#{record["flow"]["protocol_name"].downcase}"
				if @lookup_table.key?(srckey)
					record["flow"]["serviceName"] = @lookup_table[srckey]["serviceName"]
					record["flow"]["serviceDescription"] = @lookup_table[srckey]["serviceDescription"]
					record["flow"]["serviceDirection"] = "src"

				elsif @lookup_table.key?(dstkey)
					record["flow"]["serviceName"] = @lookup_table[dstkey]["serviceName"]
					record["flow"]["serviceDescription"] = @lookup_table[dstkey]["serviceDescription"]
					record["flow"]["serviceDirection"] = "dst"
				end

			 end
			record
		end # def filter

	private

		# overwrite
		def sqlCREATE
			# nothing to do
		end

    
		def create_lookup_table()
			begin			
				lookup_table = {}
				if !dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
					return lookup_table
				end

				rs = @db.exec("SELECT protoPort, serviceName, serviceDescription FROM service")
				rs.each do |row|
					handle_row(lookup_table, row)
				end
#				$log.info "FlowServicePGFilter::create_lookup_table #{@lookup_table.size} services"

				dbClose
				return lookup_table

			rescue StandardError => e  
				log.error "FlowServicePGFilter::create_lookup_table - #{e.message}"
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
					log.error "FlowServicePGFilter row error ", row:row, error:errmsg 
				end # def handle_row_error(row, errmsg)
				
				def handle_file_err(file, err)
					log.error "FlowServicePGFilter file error ", file:file, error:err 
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