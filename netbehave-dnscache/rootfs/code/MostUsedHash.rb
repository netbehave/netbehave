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
class MostUsedHash
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
		@items[key] = {"key" => key, "value" => value, "lastUsed" => now_i}
#		@items[key]["key"] = key
#		@items[key]["value"] = value
#		@items[key]["lastUsed"] = now_i
# puts @items[key]["lastUsed"]
		@nbItems = 	@nbItems + 1
		if @nbItems > @maxItems
			STDERR.puts "FlowDeNatFilter *** ERR too many responses in cache (#{@nbItems} > #{@maxItems}), must clean"
			clean
			STDERR.puts "FlowDeNatFilter *** ERR too many responses in cache (#{@nbItems} > #{@maxItems}), after clean"
		end
	end # def

	def hasKey(key)
		return @items.key?(key)
	end # def

	def getItem(key)
		if @items.key?(key)
			@items[key]["lastUsed"] = now_i
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
	
	def replaceItem(key, value)
		if @items.key?(key)
			@items[key]["value"] = value
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
#		tooOld = 60 * 60 # 60 minutes
		while @nbItems > itemsLimit && minutes > 0
			puts "FlowDeNatFilter:clean #{minutes} minutes nb=#{nb} nbItems=#{@nbItems}" 
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
		puts "FlowDeNatFilter *** clean down to #{nbItems} [down #{nb}] p2"
		while @nbItems > itemsLimit
			@items.keys.each { | key |
					deleteItem(key)
			}
		end # while	
		puts "FlowDeNatFilter *** clean down to #{nbItems} [down #{nb}] p3"
# puts "clean down to #{nbItems} [-#{nb}]"
	end
	
	def timeSinceLastUsed(item)
#		puts "#{Time.now.to_i} - #{@lastUsed.to_i}"
		return now_i - item["lastUsed"]
	end

	
	def testCode

			@items.keys.each { | key |
#			puts key, @items[key]
#			puts @items[key]
			}

#sorted = @items.inject({}) do |h, (k, v)| 
#  h[k] = Hash[v.sort_by { |k1, v1| v1[:lastUsed] }] 
#end
sorted = @items.sort_by { |k1, v1| v1["lastUsed"] }
			sorted.each { | key, value |
#			puts key, @items[key]
			puts value
			}

	end # testCode

	private

	def now_i
		if @ts.nil?
			@ts = Time.now.to_i
		end
		@ts = @ts + 1
		return @ts
#		return Time.now.to_i
	end

end # class
