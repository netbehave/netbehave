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
require "json"
require 'ipaddr'
require 'csv'      # Sockets are in standard library

#
class AclField
	# Acceptable fields
	@@validFields = ["protocol", "protocol_name", 
		"ip_version", "host", "source", 
		"src/arin/name", "dst/arin/name", 
		"dst/ip", "dst/ip_i", "dst/port", "dst/domain", "dst/network", "dst/host/name", "dst/netblock/name", 
		"src/ip", "src/ip_i", "src/port", "src/domain", "src/network", "src/host/name", "src/netblock/name", 
		"bytes", "packets", "match", "serviceName"]
	@@operators = ["!=", "=", "<", ">"]

	def initialize(toParse) #field[op]value
# puts "AclField:[#{toParse}]"
		
		@operator = nil
		cols = [toParse] # toParse.split("=")
		if toParse.match(Regexp.union(@@operators)) 
				@@operators.each{ | op | 
						cols = toParse.split(op)
						@operator = op
						if cols.length > 1
#							@value = cols[0]
#							@value = cols[2]
						end
						break if cols.length > 1
				}
#			puts "AclField:Operator found in list [#{@operator}] #{cols}"
		else
			puts "AclField:Operator not found in list [#{@@operators.join(',')}] for [#{toParse}]"
		end

		if !validateField(cols[0])
			# throw
			puts "AclField:validateField error"

		end
		@sValue = toParse
		parseValue(cols[1])
	end # def initialize

	def match(flow)
		bResult = false
		if @fields.nil?
			return bResult
		end
		value = nil

# puts aF.size
		if @fields.length > 1
			subjs = flow
			i = 1
			begin
				if !subjs.key?(@fields[i-1])
					i = 1000
				else
					subjs = subjs[@fields[i-1]]
					i = i + 1
				end
	# puts subjs.inspect
	# puts aF[i-1]
			end while i < @fields.length
	# puts subjs.inspect
			if i < 1000
				value = subjs[@fields[@fields.length-1]]
			end
		else
			if !flow.key?(@fields[0])
				value = nil
			else			
				value = flow[@fields[0]]
			end
		end
		
		if value.nil? 
			return false
		end

		value = value.to_s

		case @operator
		when "="
# puts "AclField #{value} == #{@value}"
			if value == @value
				bResult = true
			end
#			result = (value == @value)
#		else
		when "!="
			if value != @value
				bResult = true
			end
		when "<"
			if value.to_i < @value.to_i
				bResult = true
			end
		when ">"
			if value.to_i < @value.to_i
				bResult = true
			end
		when "endsWith"
			if value.to_s.end_with?(@value.to_s)
				bResult = true
			end
		when "startsWith"
			if value.to_s.start_with?(@value.to_s)
				bResult = true
			end
		when "contains"
			if value.to_s.include?(@value.to_s)
#puts "#{value} == #{@value}"
				bResult = true
			end
		when "IPinRange"
			ipaddr1 = IPAddr.new @value.to_s
			ipaddr2 = IPAddr.new value.to_s
			if ipaddr1.include?(ipaddr2)
#puts "#{value} == #{@value}"
				bResult = true
			end
		when "inlist"
			if @value.include?(",#{value.to_s},")
#puts "#{value} == #{@value}"
				bResult = true
			end		
		end
# puts "FieldMatch::match(#{@field})  => #{bResult}"
		return bResult
	end
	
	def field_to_s
		return @sValue
	end

	private
	
	def validateField(field)
#puts "field:[#{field}]"
		#if ";protocol;protocol_name;dst/ip;dst/port;src/ip;src/port;src/domain;bytes;".include?(";"+field+";")
		if @@validFields.include?(field)
			if field.include?("/")
				@fields = field.split("/")
			else
				@fields = [field]
			end
		else
			return false
		end
	end
	
	def parseValue(v)
		if v.include?("*")
			if v.start_with?("*") && v.end_with?("*") 
				@value = v[1..-2]
				@operator = "contains"
			elsif v.start_with?("*") 
				@value = v[1..-1]
				@operator = "endsWith"
			elsif v.end_with?("*") 
				@value = v[0..-2]
				@operator = "startsWith"
			else
				# TODO: WTF? not supported
			end
#			puts "op[#{@operator}] v[#{@value}] #{v}"
		elsif v.include?("/") && @fields[@fields.length-1] == "ip"
			@value = v
			@operator = "IPinRange"
			
		elsif v.start_with?("[") && v.end_with?("]") 
			@value = ",#{v[1..-2]}," 
			@operator = "inlist"			
		else
			@value = v.to_s
		end
	end

end # class AclField


class CSV_ACL
	def initialize(filename, type = 'file')
		@rules = []
		@nbRules = 0
		if type == 'file'
			create_lookup_table(filename)
		elsif type == 'array'
			create_lookup_table_from_array(filename)
		end

	end # def initialize
		
	def addOtherACL(other)
		@rules = @rules + other.rules
	end
	
	def rules
		return @rules
	end
		
	def match(flow)
		@rules.each { | rule |
			if MatchRule(rule, flow)
				return rule["name"]
			end
		}
		return nil
	end
	
	private
	
	def MatchRule(rule, flow)
		bResult = true
		rule["fields"].each { | field |
			if !field.match(flow)
				bResult = false
			end
		}
		return bResult	
	end 
	
	def create_lookup_table_from_array(aq)
		rowno = 0
		aq.each do |q|
			rowno = rowno + 1
			row = q.split(',')
			parse_rowq(row, rowno)
		end
$log.info "create_lookup_table_from_array::Loaded #{rowno} rows for #{@nbRules} rules"
#		puts 
		#                 end
#		return lookup_table
	end # def create_lookup_table
	
	
	def create_lookup_table(file)
		rowno = 0
		CSV.foreach(file) do |row|
			rowno = rowno + 1
			if !row[0].start_with?("#") # skip comments
				parse_row(row)
			end
		end
$log.info "create_lookup_table::Loaded #{rowno} rows for #{@nbRules} rules"
#		puts 
		#                 end
#		return lookup_table
	end # def create_lookup_table
	
	def parse_row(row)
		aclName = row[0]
		fields = []
		(1..row.length-1).each do |col|
			fields[col-1] = AclField.new(row[col])
		end
		@rules[@nbRules]  = {}
		@rules[@nbRules]["name"] = aclName
		@rules[@nbRules]["fields"] = fields
		
		@nbRules = @nbRules + 1
	end
	
	def parse_rowq(row, rowno)
		aclName = rowno
		fields = []
		(0..row.length-1).each do |col|
			fields[col] = AclField.new(row[col])
		end
		@rules[@nbRules]  = {}
		@rules[@nbRules]["name"] = aclName
		@rules[@nbRules]["fields"] = fields
		
		@nbRules = @nbRules + 1
	end
	
end #class CSV_ACL