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

require "fluent/plugin/output"
require "socket"

module Fluent
  module Plugin
    class DnsCacheOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("DnsCache", self)

		config_param :outlabel, :string, :default => nil
		config_param :host, :string,  default: '127.0.0.1'
		config_param :port, :integer, default: nil

		def configure(conf)
			super
			@in_key_name = "logline"
			@destLabel = ""
			if (@destLabel.nil? || @destLabel.empty?)
				if outlabel.nil?
					# no else tag
				else
					@destLabel = outlabel
				end
			end
		end
		
		def start
			super
#                    connect				
		end

		def shutdown
			super
			disconnect
		end		
		
		def emit(tag, es, chain)
#			#		$log.debug "FlowassetOutput.emit "
			es.each do |time, record|
				handle_record(tag, time, record)
			end
			chain.next
		end # def emit

		def process(tag, es)
		#		$log.debug "FlowassetOutput.process "
			es.each do |time, record|
				handle_record(tag, time, record)
			end
		end # def process

		private
		
		def handle_record(tag, time, record)
			logline = record[@in_key_name]
			action = "disregard" # disregard all other

# log.info "DnsCacheOutput::filter logline:[#{logline}]"

			if (logline =~ /^query/) 
#query[A] google.com from 172.17.0.1
				action = "query"
				record["action"] = action
				record["domain"] = logline[/(?<action>([a-zA-Z])+)(\[)(?<type>([a-zA-Z])+)(\])(\s)(?<domain>(.)+)(\s)(?<verb>(.)+)(\s)(?<result>(.+))\Z/, "domain"] 
				record["ip"] = logline[/(?<action>([a-zA-Z])+)(\[)(?<type>([a-zA-Z])+)(\])(\s)(?<domain>(.)+)(\s)(?<verb>(.)+)(\s)(?<result>(.+))\Z/, "result"] 
#				record["type"] = logline[/(?<action>([a-zA-Z])+)(\[)(?<type>([a-zA-Z])+)(\])(\s)(?<domain>(.)+)(\s)(?<verb>(.)+)(\s)(?<result>(.+))\Z/, "type"] 
				if (record["domain"] =~ /(.*)\.internal\Z/) 
				else
					if (@source) 
						toDnsModule(record)
					else
						# TODO ???
					end 
				end
				# puts "Query ", record["domain"], time, time.to_i
			end

			if (logline =~ /^reply/)
				#there can be multiple reply replies
				#reply google.com is 172.217.13.110
				#puts "in reply"
				action = "reply"
				record["action"] = action
				record["ip"] =     logline[/(?<action>([a-zA-Z0-9.\[\]])+)(\s)(?<domain>([a-zA-Z0-9.])+)(\s)(?<verb>([a-zA-Z0-9.])+)(\s)(?<result>(.)+)\Z/, "result"] 
				record["domain"] = logline[/(?<action>([a-zA-Z0-9.\[\]])+)(\s)(?<domain>([a-zA-Z0-9.])+)(\s)(?<verb>([a-zA-Z0-9.])+)(\s)(?<result>(.)+)\Z/, "domain"] 
#				record["verb"] = logline[/(?<action>([a-zA-Z0-9.\[\]])+)(\s)(?<domain>([a-zA-Z0-9.])+)(\s)(?<verb>([a-zA-Z0-9.])+)(\s)(?<result>(.)+)\Z/, "verb"] 
#					record["domain"] = logline[/(?<action>([a-zA-Z0-9.\[\]])+)(\s)(?<domain>([a-zA-Z0-9.])+)(\s)(?<verb>([a-zA-Z0-9.])+)(\s)(?<result>([a-zA-Z0-9.])+)\Z/, "domain"] 
				if record["ip"] == "<CNAME>"
					p "Domain is CNAME", domain:record["domain"], ip:record["ip"]
				else
				
					# addDomainIP(record["domain"], record["ip"], time)
					if (@source) 
						toDnsModule(record)
					else
						toDnsModule(record)
					end 
				end
			end

			if (logline =~ /^cached/)
				#there can be multiple cached replies
				#cached google.com is 172.217.13.110
				action = "cached"
				record["action"] = action

				record["ip"] = logline[/(?<action>([a-zA-Z0-9.\[\]])+)(\s)(?<domain>([a-zA-Z0-9.])+)(\s)(?<verb>([a-zA-Z0-9.])+)(\s)(?<result>([a-zA-Z0-9.])+)\Z/, "result"]
				record["domain"] = logline[/(?<action>([a-zA-Z0-9.\[\]])+)(\s)(?<domain>([a-zA-Z0-9.])+)(\s)(?<verb>([a-zA-Z0-9.])+)(\s)(?<result>([a-zA-Z0-9.])+)\Z/, "domain"] 
#				record["verb"] = logline[/(?<action>([a-zA-Z0-9.\[\]])+)(\s)(?<domain>([a-zA-Z0-9.])+)(\s)(?<verb>([a-zA-Z0-9.])+)(\s)(?<result>([a-zA-Z0-9.])+)\Z/, "verb"] 
#				cachedDomain(record["domain"], record["ip"], time)
#							toDnsModule(record)
			end


# log.info "full record: #{record.inspect}"

			# puts "DnsmoduleOutput::filter action:#{action}" 
			if (action != "disregard")					
				record[@out_key_name] = action
				# reemit record
# puts "reemit record"
			end
		end # def

		def toDnsModule(frecord)
# log.info "toDnsModule: #{frecord.inspect}"
				tries = 0    				
				begin
					connect
					tries ||= 3
					@sock.puts frecord.to_json
					response = @sock.gets
# log.info "response: #{response}"
#					chunk.write_to(@sock)
				rescue => e
				  if (tries -= 1) > 0
						disconnect #reconnect
						retry
				  else
						$log.warn("Failed writing data to socket: #{e}")
						disconnect
				  end
				end
		end


		def connect
# log.info "connect TCPSocket.new(#{@host}, #{@port})"
	#      TCPSocket.open(hostname, port)
		  @sock ||= TCPSocket.new(@host, @port)
		end

		def disconnect
		  @sock.close rescue nil
		  @sock = nil
		end

		def reconnect
		  disconnect
		  connect
		end

    end # class DnsCacheOuput
  end # module Plugin
end # module Fluent