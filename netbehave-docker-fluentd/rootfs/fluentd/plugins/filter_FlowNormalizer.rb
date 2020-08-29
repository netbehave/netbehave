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
require "csv"


module Fluent
  module Plugin
        class FlowNormalizerFilter < Fluent::Plugin::Filter
        Fluent::Plugin.register_filter('FlowNormalizer', self)

				config_param :keep_only_flowinfo, :bool, default: false
				config_param :strict, :bool, :default => false
    			config_param :local_networks, :string, default: nil

                def configure(conf)
                        super
                        table_file = File.expand_path('../filter_FlowNormalizer_proto.csv', __FILE__)
                        @lookup_table = create_lookup_table(table_file)

						@networkRanges = {}
#						log.debug "FlowNormalizerFilter local_networks=[#{local_networks}]"
#						log.debug "FlowNormalizerFilter @local_networks=[#{@local_networks}]"

						local_networks.split(";").each { |ln|
							aln = ln.split("=")
							@networkRanges[aln[1]] = aln[0]
						}
						
						log.debug "FlowNormalizerFilter ", networkRanges:@networkRanges
                end
                def start
                        super
#                    connect
                end
                def shutdown
                        super
                end
                def filter(tag, time, record)					
					flow = {}
					flow["src"] = {}
					flow["dst"] = {}
					flow["time"] = time
					other = {}

					record.each_pair { |key, value|
				        case key
				        
				        when "version"; 			flow["version"] = value ; flow["source"] = "NetFlow/IPFix v#{value}"
				        when "flow_seq_num"; 		flow["seq_num"] = value
				        when "flowset_id"; 			flow["set_id"] = value
				        when "ip_protocol_version"; flow["ip_version"] = value
				        when "host"; 				flow["host"] = value
				        when "direction";	  		flow["direction"] = value
				        when "protocolIdentifier"; 	flow["protocol"] = value
				        when "protocol";	  		flow["protocol"] = value 
#				        when "in_bytes","out_bytes";flow["bytes"] = value
#				        when "in_pkts","out_pkts";	flow["packets"] = value
				        when "in_bytes";  flow["bytes"] = value; flow["in_bytes"] = value
				        when "out_bytes"; flow["bytes"] = value; flow["out_bytes"] = value
				        when "in_pkts";	 flow["packets"] = value; flow["in_packets"] = value
				        when "out_pkts"; flow["packets"] = value; flow["out_packets"] = value
				        when "tcp_flags";			flow["tcp_flags"] = value
				        when "first_switched";		flow["first_switched"] = value
				        when "last_switched";		flow["last_switched"] = value
				        # flow["ip_version"] = 4;
						# IP
				        when "sourceIPv4Address"; 	flow["src"]["ip"] = value
				        when "destinationIPv4Address"; flow["dst"]["ip"] = value
				        when "ipv4_src_addr"; 		flow["src"]["ip"] = value
				        when "ipv4_dst_addr"; 		flow["dst"]["ip"] = value
				        when "ipv6_src_addr"; 		flow["src"]["ip"] = value
				        when "ipv6_dst_addr"; 		flow["dst"]["ip"] = value
				        when "sourceIPv6Address"; 	flow["src"]["ip"] = value
				        when "destinationIPv6Address"; flow["dst"]["ip"] = value
						# MAC address
				        when "in_src_mac","out_src_mac";  	flow["src"]["mac"] = value
				        when "in_dst_mac","out_dst_mac";    flow["dst"]["mac"] = value
						# Port
				        when "l4_src_port";    				flow["src"]["port"] = value
				        when "l4_dst_port";    				flow["dst"]["port"] = value
				        when "sourceTransportPort";    		flow["src"]["port"] = value
				        when "destinationTransportPort";    flow["dst"]["port"] = value
				        when "ipv4_src_port";    flow["src"]["port"] = value
				        when "ipv4_dst_port";    flow["dst"]["port"] = value
				        else
				        	if !@keep_only_flowinfo then other[key] = value end
				        end # case
					}


                    if !flow["protocol"].nil?
						# log.info "Normalizer ", proto: flow["protocol"], name:@lookup_table[flow["protocol"].to_s]
						if @lookup_table.key?(flow["protocol"].to_s)
							flow["protocol_name"] = @lookup_table[flow["protocol"].to_s]
						else
							flow["protocol_name"] = "Unknown:#{flow["protocol"]}"
						end
					 end

					parse_network(flow["src"])
					parse_network(flow["dst"])

					 # Parse IP
					 if flow["src"]["ip"].nil?
					 	$log.error "Unknown IP addresses ", record:record
					 else
					 end

					 # Parse ports
					if (record["flow.protocol"] =~ /(6|17)/)
					  if flow["src"]["port"].nil?
						$log.error "Unknown IP ports  ", record:record
					  end
					end
					
					if flow["ip_version"].nil?
						if !flow["src"]["ip"].nil?
							if flow["src"]["ip"].include?("::")
								flow["ip_version"] = 6
							elsif flow["src"]["ip"].include?(".")
								flow["ip_version"] = 4
							elsif flow["src"]["ip"].include?(":")
								flow["ip_version"] = "eth"
							else
								$log.error "Unknown IP version  ", srcip:flow["src"]["ip"]
							end
						end
					end

					other["flow"] = flow
					record = other

					record
                end
                
                private
                
                def parse_network(flowSrcDst)
                	# default to predefined user ranges
					 @networkRanges.each_pair { |ipstart, network|
					 	if !flowSrcDst["ip"].nil?
						 	if flowSrcDst["ip"].start_with?(ipstart) 
						 		flowSrcDst["network"] = network
						 	end
					 	end

					 }
					 # https://en.wikipedia.org/wiki/Reserved_IP_addresses
					 if flowSrcDst["network"].nil?
					 	if !flowSrcDst["ip"].nil?
					 		case flowSrcDst["ip"]
					 		# RFC 1918
							when /^10\./;			flowSrcDst["network"] = "internal"
							when /^192\.168\./;		flowSrcDst["network"] = "internal"
							when /^172\.1[6-9]\./;	flowSrcDst["network"] = "internal"
							when /^172\.2[0-9]\./;	flowSrcDst["network"] = "internal"
							when /^172\.3[0-1]\./;	flowSrcDst["network"] = "internal"

							when /^127\./;			flowSrcDst["network"] = "loopback"

							# LINK-local
							when /^169\.254\./;		flowSrcDst["network"] = "link-local"
							# multicast
							when /^22[456789]\./;	flowSrcDst["network"] = "multicast"
							when /^23[0-9]\./;		flowSrcDst["network"] = "multicast"
							when "255.255.255.255";	flowSrcDst["network"] = "limited broadcast"
			
							# everything else is external
							else
								flowSrcDst["network"] = "external"	
							end # case
						end
					 end
                end # def parse_network
                
                def create_lookup_table(file)
					lookup_table = {}
					CSV.foreach(file) do |row|
						handle_row(lookup_table, row)
					end

					if (strict && lookup_table.length == 0)
						raise ConfigError, "Lookup file is empty"
					end

					return lookup_table
					rescue Errno::ENOENT => e
						handle_file_err(file, e)
					rescue Errno::EACCES => e
						handle_file_err(file, e)
				end # def create_lookup_table(file)
				
				def handle_row(lookup_table, row)
					if (row.length < 2)
						return handle_row_error(row, "Too few columns : #{row.length} instead of 2")
					end

					# If too much columns
					if (strict && row.length > 2)
						return handle_row_error(row, "Too much columns : #{row.length} instead of 2")
					end

					# If duplicates
					if (strict && lookup_table.has_key?(row[0]))
						return handle_row_error(row, "Duplicate entry")
					end

					lookup_table[row[0]] = row[1]
					#$log.warn "csv pair ", row[0], row[1]
				end # def handle_row(lookup_table, row)
				
				def handle_row_error(row, errmsg)
					log.error "FlowNormalizerFilter row error ", row:row, error:errmsg 
				end # def handle_row_error(row, errmsg)
				
				def handle_file_err(file, err)
					log.error "FlowNormalizerFilter file error ", file:file, error:err 
				end # def handle_file_err(file, err)
				
				
		
class MostUsedQueue
	def initialize(maxItems = 1024, ttlSec = 1800)
		@maxItems = maxItems
		@ttlSec = ttlSec
		@items = {}
		@nbItems = 0
	end # def initialize

	def nbItems # getter
		@nbItems
	end #def

	def addItem(key, value)
		@items[key] = value
		@items[key]["lastUsed"] = Time.now
		@nbItems = 	@nbItems + 1
		if @nbItems > @maxItems
			puts "*** ERR too many responses in cache, must clean"
			clean
		end
	end # def

	def hasKey(key)
		return @items.key?(key)
	end # def

	def getItem(key)
		if @items.key?(key)
			@items[key]["lastUsed"] = Time.now
			return @items[key]
		end
		return nil
	end # def

	def deleteItem(key)
		if @items.key?(key)
			@items.delete(key)
			@nbItems = 	@nbItems - 1
			return true
		end
		return false
	end # def
	
	def clean
		# we want to remove at leas 1/4 of all items since this is an expensive operation
		itemsLimit = @maxItems - (@maxItems / 4)
		nb = 0
		minutes = 60
		tooOld = 60 * 60 # 60 minutes
		while @nbItems > itemsLimit
			@items.keys.each { | key |
				if @items[key].nil?
					deleteItem(key)
				else
					if timeSinceLastUsed(@items[key]) > (minutes * 60)
						nb = nb + 1
						deleteItem(key)
					end
				end
			}
			
			if minute > 10
			minutes = minutes - 5 #(1 * 60) # drop by 5 minutes each step
			else
			minutes = minutes - 1 #(1 * 60) # drop by 5 minutes each step
			end
		end # while		
 puts "clean down to #{nbItems} [-#{nb}]"
	end
	
	def timeSinceLastUsed
#		puts "#{Time.now.to_i} - #{@lastUsed.to_i}"
		return Time.now - @items[key]["lastUsed"]
	end


	private

end # class
		
		end # class
    end #  module Plugin
end # module Fluent