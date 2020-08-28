require "fluent/plugin/filter"
require "csv"

module Fluent
  module Plugin
        class FlowDeNatFilter < Fluent::Plugin::Filter
        Fluent::Plugin.register_filter('FlowDeNat', self)

				config_param :mapNatSrcNetwork, :string, default: nil
				config_param :mapNatDstNetwork, :string, default: nil

                def configure(conf)
                        super
						
						if (!@mapNatSrcNetwork.nil? && !@mapNatDstNetwork.nil?)
							@natPorts = MostUsedQueue.new(log, 10240)
						else
							@natPorts = nil
						end
						
						log.debug "FlowDeNatFilter ", networkRanges:@networkRanges
                end
                def start
                        super
#                    connect
                end
                def shutdown
                        super
                end
                def filter(tag, time, record)
					flow = record["flow"]

					# fix NATed ports
					if !@natPorts.nil?
						 if !flow["src"]["network"].nil? && !flow["dst"]["network"].nil?
							if flow["src"]["network"] == @mapNatSrcNetwork && flow["dst"]["network"] == "external"
								 # src = home, dst = external => creates NAT
								 natPortKey = "#{flow['dst']['ip']}/#{flow['protocol_name']}/#{flow['dst']['port']}"
								 natPort = {}
								 natPort["proto"] = flow["protocol_name"]
								 natPort["port"] = flow["dst"]["port"]
								 natPort["srcip"] = flow["src"]["ip"]
								 natPort["dstip"] = flow["dst"]["ip"]
								 @natPorts.addItem(natPortKey, natPort)
								 flow["denat"] = "add"
							elsif flow["src"]["network"] == "external" && flow["dst"]["network"] == @mapNatDstNetwork
								 # src = external, dst = NAT => uses NAT
								 natPortKey = "#{flow['src']['ip']}/#{flow['protocol_name']}/#{flow['src']['port']}"
								 if @natPorts.hasKey(natPortKey)
								 	natPort = @natPorts.getItem(natPortKey)
								 	if natPort["dstip"] == flow["src"]["ip"]
									 	flow["dst"]["natip"] = flow["dst"]["ip"]
									 	flow["dst"]["ip"] = natPort["srcip"]
									 	flow["dst"]["network"] = mapNatSrcNetwork
									 	flow["denat"] = "dst"
									 else
									 	flow["denat"] = "dstip!=src/ip"
									 end
								 else
									flow["denat"] = "unknown"
								 end
							elsif flow["dst"]["network"] == "external" && flow["src"]["network"] == @mapNatDstNetwork
								 # src = external, dst = NAT => uses NAT
								 natPortKey = "#{flow['dst']['ip']}/#{flow['protocol_name']}/#{flow['dst']['port']}"
								 if @natPorts.hasKey(natPortKey)
								 	natPort = @natPorts.getItem(natPortKey)
								 	if natPort["dstip"] == flow["src"]["ip"]
									 	flow["src"]["natip"] = flow["src"]["ip"]
									 	flow["src"]["ip"] = natPort["srcip"]
									 	flow["src"]["network"] = mapNatSrcNetwork
									 	flow["denat"] = "src"
									 else
									 	flow["denat"] = "dstip!=src/ip"
									 end
								 else
									flow["denat"] = "unknown"
								 end
							end
						end
					end # if !@natPorts.nil?
					 
					record
                end
                
                private
                
		
class MostUsedQueue
	def initialize(log, maxItems = 1024, ttlSec = 1800)
		@maxItems = maxItems
		@ttlSec = ttlSec
		@items = {}
		@nbItems = 0
		@log = log
	end # def initialize

	def nbItems # getter
		@nbItems
	end #def

	def addItem(key, value)
#		@items[key] = {}
		@items[key] = {"key" => key, "value" => value, "lastUsed" => now_i}
#		@items[key]["value"] = value
#		@items[key]["lastUsed"] = Time.now
		@nbItems = 	@nbItems + 1
		if @nbItems > @maxItems
#			@log.warn "FlowDeNatFilter *** ERR too many responses in cache (#{@nbItems} > #{@maxItems}), must clean"
			clean
#			@log.warn "FlowDeNatFilter *** ERR too many responses in cache (#{@nbItems} > #{@maxItems}), after clean"
		end
	end # def

	def hasKey(key)
		return @items.key?(key)
	end # def

	def getItem(key)
		if @items.key?(key)
			@items[key]["lastUsed"] = now_i # Time.now
			return @items[key]["value"]
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
		itemsLimit = @maxItems - (@maxItems / 4)

		sorted = @items.sort_by { |k1, v1| v1["lastUsed"] }

		sorted.each { | key, value |
#			puts key, @items[key]
#			puts value
			deleteItem(key)
			break if @nbItems < itemsLimit
		}
	end #clean
	
	def clean2
		# we want to remove at leas 1/4 of all items since this is an expensive operation
		itemsLimit = @maxItems - (@maxItems / 4)
		nb = 0
		minutes = 60
		tooOld = 60 * 60 # 60 minutes
		while @nbItems > itemsLimit && minutes > 0
# @log.warn "FlowDeNatFilter:clean #{minutes} minutes nb=#{nb} nbItems=#{@nbItems}" 
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
			
			if minutes > 10
			minutes = minutes - 5 #(1 * 60) # drop by 5 minutes each step
			else
			minutes = minutes - 1 #(1 * 60) # drop by 5 minutes each step
			end
		end # while		
		while @nbItems > itemsLimit
			@items.keys.each { | key |
					deleteItem(key)
			}
		end # while	
			@log.warn "FlowDeNatFilter *** clean down to #{nbItems} [-#{nb}]"
# puts "clean down to #{nbItems} [-#{nb}]"
	end
	
	def timeSinceLastUsed(item)
#		puts "#{Time.now.to_i} - #{@lastUsed.to_i}"
		return now_i - item["lastUsed"]
	end


	private

	def now_i
		return Time.now.to_i
	end

end # class
		
		end # class
    end #  module Plugin
end # module Fluent