#
# Copyright 2018: Yves B. Desharnais
#
# This file is part of NetBehave available at NetBehave.org.
# 
# NetBehave is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# NetBehave is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with NetBehave.  If not, see <https://www.gnu.org/licenses/>.
# 
require "fluent/plugin/filter"
require "json"
require 'ipaddr'
require 'net/http'
require 'sqlite3'
#require "FileUtils"
require 'csv'      # Sockets are in standard library

require_relative 'nbacl_classes' # .rb

module Fluent
  module Plugin
    class FlowMatchACLFilter < Fluent::Plugin::Filter
        Fluent::Plugin.register_filter('FlowMatchACL', self)

		config_param :aclFile, :string, :default => nil
		config_param :aclField, :string, :default => nil

		def configure(conf)
			super
			if @aclFile.nil? || !File.file?(@aclFile)
				@rules = CSV_ACL.new( File.expand_path('../acl.csv', __FILE__) )
			else
				@rules = CSV_ACL.new(@aclFile)
			end
			log.info "FlowMatchACLFilter #{@rules.rules.length} rules loaded"

#			log.debug "FlowDnsModuleFilter "
			# @dbPath = dbfile
		end
		
		def start
			super
#                    connect				
		end

		def shutdown
			super
		end		

		def filter(tag, time, record)	
			 if !record["flow"].nil?
				ruleName = @rules.match(record["flow"])
				if ruleName.nil?				
			        record["flow"][@aclField] = "NOMATCH"
				else
			log.info "FlowMatchACLFilter:filter found rule [#{ruleName}]"
			        record["flow"][@aclField] = ruleName
				end
			 end

			record
		end
				
		end # class
    end #  module Plugin
end # module Fluent