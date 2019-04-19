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
#require 'sqlite3'
#require "FileUtils"
#require 'csv'      # Sockets are in standard library

require_relative 'nbacl_classes_pg' # .rb


module Fluent
  module Plugin
    class FlowMatchACLPGFilter < Fluent::Plugin::Filter

        Fluent::Plugin.register_filter('FlowMatchACLPg', self)

		config_param :aclField, :string, :default => nil
		config_param :dbhost, :string,  default: 'localhost'
		config_param :dbname, :string,  default: 'postgres'
		config_param :dbuser, :string,  default: 'postgres'
		config_param :dbpass, :string,  default: 'postgres'

		def configure(conf)
			super
			@rules = nil
		end
		
		def start
			super
		end

		def shutdown
			super
		end		

		def filter(tag, time, record)	
			if @rules.nil?
				dbLoad
			end
			if !@rules.nil?
				 if !record["flow"].nil?
					ruleName = @rules.match(record["flow"])
					if ruleName.nil?				
						record["flow"][@aclField] = "NOMATCH"
					else
						record["flow"][@aclField] = ruleName
						log.debug "FlowMatchACLPGFilter:filter found rule [#{ruleName}]"
					end
				 end
			end

			record
		end

                
		private
				def dbLoad
					begin
						if @rules.nil?
							log.info "FlowMatchACLPGFilter::dbLoad #{@dbhost}/#{@dbname}"
							@rules = PG_ACL.new(@dbhost, @dbname, @dbuser, @dbpass)
						end
					rescue StandardError => e  
						log.error "FlowMatchACLPGFilter::dbLoad - #{e.message}"
						# puts e.backtrace.inspect 
						@rules = nil
					end
					
				end 

		end # class


    end #  module Plugin
end # module Fluent

=begin
-- Table: public.acl

-- DROP TABLE public.acl;

CREATE TABLE public.acl
(
    rulename text COLLATE pg_catalog."default" NOT NULL,
    rulecsv text COLLATE pg_catalog."default" NOT NULL
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.acl
    OWNER to postgres;
=end