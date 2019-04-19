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
    class FlowArinWhoisPgFilter < Fluent::Plugin::Filter
    	include PgClasses # mixin used since multiple inheritance is not possible in Ruby
    	
        Fluent::Plugin.register_filter('FlowArinWhoisPg', self)

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
			 if !record["flow"]["src"]["ip"].nil?
				 if !record["flow"]["src"]["network"].nil?
					if record["flow"]["src"]["network"] == "external"
				 		if record["flow"]["src"]["domain"].nil?
							reverseDNS(record["flow"]["src"]["ip"], record["flow"]["src"], "src")
						end
					end
				 end
			 end
			 
			 if !record["flow"]["dst"]["ip"].nil?
				 if !record["flow"]["dst"]["network"].nil?
					if record["flow"]["dst"]["network"] == "external"
				 		if record["flow"]["dst"]["domain"].nil?
							reverseDNS(record["flow"]["dst"]["ip"], record["flow"]["dst"], "dst")
						end
					end
				 end
			 end

			record
		end

                
        private

		def reverseDNS(ip, frecord, srcdst)
			# log.warn "Arin.reverseDNS #{ip} #{srcdst}"
			row = sqlExists(ip)
			if row.nil?
				# log.warn "Arin.reverseDNS not found #{ip} #{srcdst}"
				arinWhois(ip, frecord)
			else
				arin = {}
				arin["name"] 			= row[0]
				arin["startAddress"] 	= row[1]
				arin["endAddress"] 		= row[2]
				frecord["arin"] = arin

			end
		end	            

		def arinWhois(ip, frecord)
			# log.warn "Arin.whois #{ip} "
			url = "http://whois.arin.net/rest/ip/#{ip}"

			begin
				uri = URI.parse(url)
				http = Net::HTTP.new(uri.host, uri.port)
				request = Net::HTTP::Get.new(uri.request_uri)
				request["Accept"] = "application/json"
				response = http.request(request)
				js = response.body
				o = JSON.parse(js)
				
				arin = {}
				arin["name"] 			= o["net"]["name"]["$"]
				arin["startAddress"] 	= o["net"]["startAddress"]["$"]
				arin["endAddress"] 		= o["net"]["endAddress"]["$"]
				sqlINSERT(arin)
				frecord["arin"] = arin
#			rescue => e
#				log.error "arinWhois Error", e
			rescue JSON::ParserError
				log.warn "JSON error parsing [#{line.chomp}]"
				#"ERR|JSON error #{line.chomp}"			
			end

		end


		# overwrite
		def sqlCREATE()
		rows = @db.exec <<-SQL 
				CREATE TABLE IF NOT EXISTS arinwhois 
				(
					startAddress bigint,
					endAddress bigint,
					startAddressIP varchar(20),
					endAddressIP varchar(20),
					numAddresses int,
					whoisname varchar(200),
					dateAdded bigint,
					PRIMARY KEY (startAddress, endAddress)

				);
			SQL
		end
		
		def sqlINSERT(arin)
			if !dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
				return
			end

#			now = DateTime.now
			now = Time.now
			startAddressIP = IPAddr.new(arin["startAddress"], Socket::AF_INET)
			endAddressIP = IPAddr.new(arin["endAddress"], Socket::AF_INET)
			rows = @db.exec_params("INSERT INTO arinwhois (startAddress, endAddress, startAddressIP, endAddressIP, numAddresses, whoisname, dateAdded) VALUES($1, $2, $3, $4, $5, $6, $7)", 
				[startAddressIP.to_i, endAddressIP.to_i, arin["startAddress"], arin["endAddress"], 
				endAddressIP.to_i - startAddressIP.to_i + 1, arin["name"], now.to_i])
		end #def

		
		def sqlExists(ip)
			if !dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
				return nil
			end
			ipaddr = IPAddr.new(ip, Socket::AF_INET)

			rows = @db.exec_params("SELECT whoisname, startAddressIP, endAddressIP FROM arinwhois WHERE startAddress <= $1 AND endAddress >= $2 ", [ipaddr.to_i, ipaddr.to_i])
			# log.warn "Arin.sqlExists #{ipaddr} : #{rows.num_tuples}"
			if rows.nil?
				return nil
			end
			if rows.num_tuples == 0 
				return nil
			end

			row = nil
			rows.each do |_row|
				if row.nil?
					row = _row
				end
			end
			# log.warn "Arin.sqlExists #{ipaddr} : #{row.to_s}"
			
			return row # "hits"
		end #def
				
		end # class
    end #  module Plugin
end # module Fluent
 

