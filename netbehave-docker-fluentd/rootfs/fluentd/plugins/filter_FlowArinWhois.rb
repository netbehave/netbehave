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

module Fluent
  module Plugin
    class FlowArinWhoisFilter < Fluent::Plugin::Filter
        Fluent::Plugin.register_filter('FlowArinWhois', self)

		config_param :dbfile, :string, :default => nil
		config_param :onlyNoDomains, :bool, :default => false # TODO

		def configure(conf)
			super
		end
		
		def start
			super
			dbOpen
		end

		def shutdown
			super
			dbClose
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
			if row == nil
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
 log.warn "Arin.whois #{ip} "
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

		def dbClose
			if !@db.nil?
				@db.close
				@db = nil
			end
		end 
		def dbOpen
			@db = ::SQLite3::Database.open @dbfile
			sqlCREATE
		end
        
		def sqlCREATE()
		rows = @db.execute <<-SQL 
				CREATE TABLE IF NOT EXISTS whois 
				(
					startAddress int,
					endAddress int,
					startAddressIP varchar(20),
					endAddressIP varchar(20),
					numAddresses int,
					whoisname varchar(200),
					dateAdded int,
					PRIMARY KEY (startAddress, endAddress)

				);
			SQL
		end
		
		def sqlINSERT(arin)
#			now = DateTime.now
			now = Time.now
			startAddressIP = IPAddr.new(arin["startAddress"], Socket::AF_INET)
			endAddressIP = IPAddr.new(arin["endAddress"], Socket::AF_INET)
			rows = @db.execute("INSERT INTO whois (startAddress, endAddress, startAddressIP, endAddressIP, numAddresses, whoisname, dateAdded) VALUES(?, ?, ?, ?, ?, ?, ?)", 
				[startAddressIP.to_i, endAddressIP.to_i, arin["startAddress"], arin["endAddress"], 
				endAddressIP.to_i - startAddressIP.to_i + 1, arin["name"], now.to_i])
		end #def

		
		def sqlExists(ip)
			ipaddr = IPAddr.new(ip, Socket::AF_INET)
			rows = @db.execute("SELECT whoisname, startAddressIP, endAddressIP FROM whois WHERE startAddress <= ? AND endAddress >= ? ", [ipaddr.to_i, ipaddr.to_i])
	
			if rows.nil?
				return nil
			end
			if rows.length == 0 
				return nil
			end
			row = rows[0]
			if row[0].nil? || row[0] == ""
				return nil
			end
			return row # "hits"
		end #def
				
		end # class
    end #  module Plugin
end # module Fluent
 

