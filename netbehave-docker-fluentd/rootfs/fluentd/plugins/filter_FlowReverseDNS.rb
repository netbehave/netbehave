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
require 'resolv'
# require_relative "rules_engine"
#require 'ipaddr'
#require 'net/http'
#require 'sqlite3'
require "socket"


module Fluent
  module Plugin
    class FlowReverseDNSFilter < Fluent::Plugin::Filter
      Fluent::Plugin.register_filter("FlowReverseDNS", self)

# TODO: allow not local?
		config_param :dnsCacheServer, :string, :default => "127.0.0.1"
		config_param :dnsCachePort, :integer, :default => 10001


	def start
		super
#                    connect
	end
	def shutdown
		super
		disconnect
	end


	def configure(conf)
		super
#		log.info "FlowIdentifierFilter:Engine #{@engine.size} rules loaded"
	end

		def filter(tag, time, record)					
			 if !record["flow"]["src"]["ip"].nil?
				 if !record["flow"]["src"]["network"].nil?
					if record["flow"]["src"]["network"] == "external"
						reverseDNS(record["flow"]["src"]["ip"], record["flow"]["src"])

					end
				 end
			 end
			 
			 if !record["flow"]["dst"]["ip"].nil?
				 if !record["flow"]["dst"]["network"].nil?
					if record["flow"]["dst"]["network"] == "external"
						reverseDNS(record["flow"]["dst"]["ip"], record["flow"]["dst"])

					end
				 end
			 end

			record
		end # def filter

	private
	
	def reverseDNS(ip, frecord)
# log.warn "Doing resolv"
				if frecord["domain"].nil? 
					begin
						oQuery = {}
						oQuery["action"] = "reverseDNS"
						oQuery["ip"] = ip
						domain = toSocket(oQuery)
#						log.warn "resolv #{ip} => #{domain}"
						if !domain.nil?
							# TODO : update DNSModule????
							frecord["domain"] = domain
						end
					rescue => e
						log.error "FlowReverseDNSFilter Exception ", e
					end
				end
		end

			def toSocket(oQuery)
				tries = 0    				
				begin
					if @sock.nil?
						connect
					end
					tries ||= 3
#		log.warn("query: #{oQuery.to_json}")
					@sock.puts oQuery.to_json
					respline = @sock.gets
#		log.warn("response: #{respline}")
					
					oResp = JSON.parse(respline)					
					if oResp["status"] == "OK"
						return oResp["rdns"][0]["domain"]
					end
#grep -v '"serviceName":"domain' debug2/buffer.b578ee5924a138be61e5cdde445f175b5.log | grep domain
					
#					chunk.write_to(@sock)
				rescue => e
				  if (tries -= 1) > 0
						disconnect #reconnect
						retry
				  else
						log.warn("Failed writing data to socket: #{e}")
						disconnect
				  end
				end
				return nil
			end #toSocket

			def connect
			#   TCPSocket.open(hostname, port)
#				$log.info("Connecting to socket: #{@dnsCacheServer}:#{@dnsCachePort}")
				@sock ||= TCPSocket.new(@dnsCacheServer, @dnsCachePort)
			end

			def disconnect
				@sock.close rescue nil
				@sock = nil
			end

			def reconnect
				disconnect
				connect
			end

# unused
	def reverseDNSresolv(ip, frecord)

#log.warn "Doing resolv"
				if frecord["domain"].nil? 
					begin
						domain = Resolv.getname(ip)
#						log.warn "resolv #{ip} => #{domain}"
						if !domain.nil?
							# TODO : update DNSModule????
							frecord["domain"] = domain
						end
					rescue => e
log.error "FlowReverseDNSFilter", e
					end
				end
# 96.20.0.18
		end

    end # class
    
=begin

=end

  end
end

=begin
{"action":"reverseDNS", "ip":"17.178.96.59"}
{"action":"DNS", "domain":"apple.com"}
=end
