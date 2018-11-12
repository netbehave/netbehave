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

# TODO: cache ttl
# TODO: storage

module Fluent
  module Plugin
    class FlowIpamOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("FlowIPAM", self)


    			config_param :local_network_name, :string, default: nil
    			config_param :outlabel, :string, :default => nil
    			config_param :host, :string,  default: '127.0.0.1'
			    config_param :port, :integer, default: nil
			    config_param :secondsInactive, :integer, default: 300 # 300 sec = 5min
    
                def configure(conf)
					super
					@localIPs = {}
					@destLabel = ""
					if (@destLabel.nil? || @destLabel.empty?)
						if outlabel.nil?
							# no else tag
							else
								@destLabel = outlabel
							end
					end

#					log.info "out_FlowAsset1", local_network_name:local_network_name
#					log.info "out_FlowAsset2", local_network_name:@local_network_name
                end
                def start
                    super
#                    connect
                end
                def shutdown
                    super
                	disconnect
					@localIPs.each_pair { |key, value|
						log.info "FlowAsset", asset:value
					}
                        
                end

				def emit(tag, es, chain)
#		$log.debug "FlowassetOutput.emit "
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
					label = Engine.root_agent.find_label(@destLabel)
					router = label.event_router

					flow = record["flow"]

					if !flow["bytes"].nil?
						bytes = flow["bytes"]
					else
						bytes = 0
					end

					if flow["src"]["network"] == @local_network_name
						handle_ip(tag, time, flow["src"], bytes)

					end

					if flow["dst"]["network"] == @local_network_name
						handle_ip(tag, time, flow["dst"], bytes)

					end

				end # def handle_record
    
    			def handle_ip(tag, time, flowSrcDst, bytes)
					label = Engine.root_agent.find_label(@destLabel)
					router = label.event_router

						ip = flowSrcDst["ip"].to_s
						mac = flowSrcDst["mac"].to_s
						if @localIPs.key?(ip)
							diff = time - @localIPs[ip]["lastSeen"]
							@localIPs[ip]["lastSeen"] = time
							@localIPs[ip]["bytes"] = @localIPs[ip]["bytes"]  + bytes
							if diff > @secondsInactive 
								frecord = {}
								frecord["asset"] = @localIPs[ip]
								frecord["action"] = "update"
								frecord["type"] = "flow"
								frecord["time"] = time
								router.emit(tag, time, frecord) 
								toSocket(frecord)
							end
						else
							@localIPs[ip] = {}
							@localIPs[ip]["ip"] = ip
							@localIPs[ip]["mac"] = mac
							@localIPs[ip]["firstSeen"] = time
							@localIPs[ip]["lastSeen"] = time
							@localIPs[ip]["bytes"] = bytes
							frecord = {}
							frecord["asset"] = @localIPs[ip]
							frecord["action"] = "new"
							frecord["type"] = "flow"
							frecord["time"] = time
							router.emit(tag, time, frecord) 
							toSocket(frecord)
						end
    			end 
    			
    			def toSocket(frecord)
    				tries = 0    				
    				begin
		    			connect
						tries ||= 3
						@sock.puts frecord.to_json
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
    			end #toSocket

			def connect
			#   TCPSocket.open(hostname, port)
				$log.info("Connecting to socket: #{@host}:#{@port}")
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

    end
  end
end
