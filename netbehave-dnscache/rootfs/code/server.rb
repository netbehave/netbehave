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
require_relative 'classes' #.rb
require_relative 'TcpServerWrapper' #.rb

class DnsModuleServer < TcpMultiportServerWrapper #TcpServerWrapper
	def initialize(roPort, rwPort, adminPort)
		super(roPort, rwPort, adminPort)
		@dnsE = DnsEntries.new
		mapRO = {}
		mapRO["reverseDNS"] = lambda {|cmd| reverseDNS cmd}
		mapRO["DNS"] = lambda {|cmd| DNS cmd}
		mapRO["info"] = lambda {|cmd| inforo cmd}

		mapRW = {}
		mapRW["reverseDNS"] = lambda {|cmd| reverseDNS cmd}
		mapRO["DNS"] = lambda {|cmd| DNS cmd}
		mapRW["query"] = lambda {|cmd| query cmd}
		mapRW["reply"] = lambda {|cmd| reply cmd}
		mapRW["cached"] = lambda {|cmd| cached cmd}
		mapRW["info"] = lambda {|cmd| inforw cmd}

		mapAdmin = {}
		mapAdmin["reverseDNS"] = lambda {|cmd| reverseDNS cmd}
		mapRO["DNS"] = lambda {|cmd| DNS cmd}
		mapAdmin["info"] = lambda {|cmd| infoadmin cmd}
#		mapAdmin["rotate"] = lambda {|cmd| adminRotate cmd}
#		mapAdmin["shutdown"] = lambda {|cmd| adminShutdown cmd}

		@map = {}
		@map["read-only"] = mapRO
		@map["read-write"] = mapRW
		@map["admin"] = mapAdmin


	end # def new(port)
	
	def processLineCommand(line, connID, role)
		map = @map[role]

		if line.start_with?("info")
			action = "info"
		else
			begin
				cmd = JSON.parse(line)
				action = cmd["action"]
			rescue JSON::ParserError
				@@logger.debug "JSON error parsing [#{line.chomp}]"
					puts "JSON error parsing [#{line.chomp}]"
				return ErrorMessage("JSON error #{line.chomp}").to_json
				#"ERR|JSON error #{line.chomp}"			
			end
			@@logger.debug "Conn[#{connID}] Action:#{cmd["action"]}"
			puts "Conn[#{connID}] Action:#{cmd["action"]}"
		end

# puts map[cmd["action"]].inspect
		if map.key?(action) 
			resp = map[action].call(cmd)
		else
			resp = ErrorMessage("unknown command #{line.chomp}").to_json
		end
		@@logger.debug "Conn[#{connID}] Response:#{resp}"
		puts "Conn[#{connID}] Response:#{resp}"

		return resp.to_json
	end
	
	private
	
	def ErrorMessage(errMsg) 
		oResp = {}
		oResp["status"] = "ERR"
		oResp["error"]  = errMsg
		return oResp
	end # def

	def info(role)
		methods = []
		map = @map[role]
		if map.nil?
			@@logger.error "No methods for #{role}"
			puts "No methods for #{role}"
		else
			map.each_key { |key|
				methods << key
			}
		end
		oResp = {}
		oResp["status"] = "OK"
		oResp["server"] = "DnsModule"
		oResp["role"] = role
		oResp["methods"] = methods
		return oResp
	end
	
	def inforo(cmd)
		return info("read-only")
	end
	def inforw(cmd)
		return info("read-write")
	end
	def infoadmin(cmd)
		return info("admin")
	end

	
	def query(cmd)
		oResp = {}
		oResp["status"] = "OK"

		if !cmd.key?("domain")
			return ErrorMessage("Missing field [domain]")
		end
		domain = cmd["domain"]

		if !cmd.key?("from")
			return ErrorMessage("Missing field [from]")
		end
		from = cmd["from"]

		if !cmd.key?("type")
			# type is optional, so no error message
#			return ErrorMessage("Missing field [from]")
			type = "A"
		else
			type = cmd["type"]
		end
		
#		@dnsm.query(from, domain, type)
		# TODO: missing return values
		oResp["cmd"] = cmd
		return oResp
	end #

	def reply(cmd) # ip, domain, type = "A")
		@@logger.debug "DnsModuleServer:reply[cmd=#{cmd.inspect}]"

		oResp = {}
		oResp["status"] = "OK"

		if !cmd.key?("domain")
			return ErrorMessage("Missing field [domain]")
		end
		domain = cmd["domain"]

		if !cmd.key?("ip")
			return ErrorMessage("Missing field [ip]")
		end
		ip = cmd["ip"]

		if !cmd.key?("type")
			# type is optional, so no error message
#			return ErrorMessage("Missing field [from]")
			type = "A"
		else
			type = cmd["type"]
		end
		@dnsE.addReply(ip, domain, type) 
#		@dnsm.reply(ip, domain, type)
		# TODO: missing return values
		oResp["cmd"] = cmd
		return oResp
		
	end #

	def cached(ip, domain, type = "A")
		oResp = {}
		oResp["status"] = "OK"

		if !cmd.key?("domain")
			return ErrorMessage("Missing field [domain]")
		end
		domain = cmd["domain"]

		if !cmd.key?("ip")
			return ErrorMessage("Missing field [ip]")
		end
		ip = cmd["ip"]

		if !cmd.key?("type")
			# type is optional, so no error message
#			return ErrorMessage("Missing field [from]")
			type = "A"
		else
			type = cmd["type"]
		end
		
#		@dnsm.cached(ip, domain, type)
		# TODO: missing return values
		oResp["cmd"] = cmd
		return oResp
	end #


	def reverseDNS(cmd) # ip, from = "")
		oResp = {}
		oResp["status"] = "OK"


		if !cmd.key?("ip")
			return ErrorMessage("Missing field [ip]")
		end
		ip = cmd["ip"]

		if !cmd.key?("from")
			# from is optional, so no error message
			from = nil
		else
			from = cmd["from"]
		end
		
		
#puts "A0"		
		ardns = @dnsE.reverseDNS(ip) # , from)
#puts "A1"

		if ardns.nil? || ardns.length == 0
			return ErrorMessage("Not found [ip=#{ip}]")
		end
#puts "A2"
		if ardns.length > 1
			puts "more than one"
			oResp["rdns"] = []
			ardns.each{ | rdns | 
				oResp["rdns"].push(rdns.to_object_array)
			}
#puts "A3"
		else
		# TODO: missing return values
#puts "A3b"
#puts ardns.inspect
			rdns = ardns[0]
#puts "A4b"

			oResp["rdns"] = [rdns.to_object_array]
#puts "A5b"
		end
		return oResp
	end

	def DNS(cmd) # ip, from = "")
		oResp = {}
		oResp["status"] = "OK"


		if !cmd.key?("domain")
			return ErrorMessage("Missing field [domain]")
		end
		domain = cmd["domain"]

		if !cmd.key?("from")
			# from is optional, so no error message
			from = nil
		else
			from = cmd["from"]
		end
		
		ardns = @dnsE.DNS(domain) # , from)
		if ardns.nil? || ardns.length == 0
			return ErrorMessage("Not found [domain=#{domain}]")
		end
		if ardns.length > 1
#			puts "more than one"
			oResp["dns"] = []
			ardns.each{ | rdns | 
				oResp["dns"].push(rdns.to_object_array)
			}
		else
		# TODO: missing return values
			rdns = ardns[0]
			oResp["dns"] = [rdns.to_object_array]
		end
		return oResp
	end	
	
end #class
