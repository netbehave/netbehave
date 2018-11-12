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
require 'socket'      # Sockets are in standard library
require 'sqlite3'
require 'json'
# require 'singleton'
require 'ipaddr'
require 'logger'

logpath = ENV["IPAMLOGDIR"]
dbpath =  ENV["IPAMDATADIR"]

if dbpath.nil?
	dbpath = "/opt/netbehave/ipam"
end


# LOGFILE = "#{logpath}/ipam.log"
LOGFILE = "#{dbpath}/ipam.log"
DBFILE="#{dbpath}/asset.db"
NOTIFYNEWFILE="#{dbpath}/ipam.new"
NOTIFYCHGFILE="#{dbpath}/ipam.chg"
PATHNEWCHGFOLDER="#{dbpath}"
FILE_PERMISSION = 0644


# class_variable_set(:@@secondsInactive, 600)
@@secondsInactive = 600 # 600 = 10 minutes

TCProPort = 11001
TCPrwPort = 11002
TCPadminPort = 11003


@@logger = Logger.new STDOUT
# @@logger = Logger.new("#{LOGFILE}") # File.new("#{LOGFILE}")
# @@logger = Logger.new LOGFILE
@@logger.progname = "ipam.rb"

require_relative 'TcpServerWrapper' #.rb

=begin
OFF
FATAL
ERROR
WARN
INFO
DEBUG
TRACE
ALL
=end


class IPAssetPort
	def initialize(port, proto, status)
		@port = port
		@proto = proto
		@status = status
# puts "#{port} #{proto} #{status}"
	end
	
	def port # getter
		@port
	end #def
	def proto # getter
		@proto
	end #def
	def status # getter
		@status
	end #def

end


class IPAsset
	def initialize
		@ip = ""
		@mac = ""
		@firstSeen = 0
		@lastSeen = 0
		@ports = []
	end
	
	def fromDBrow(row)
		@ip = row[0]
		@mac = row[1]
		@firstSeen = row[2]
		@lastSeen = row[3]
	end # def
	
	def to_object_array
		oa = {}
		oa["ip"] = @ip
		oa["mac"] = @mac
		oa["firstSeen"] = @firstSeen
		oa["lastSeen"] = @lastSeen
		oa["ports"] = []
		@ports.each { | port |
			p = {}
			p["status"] = port.status
			p["port"] = port.port
			p["proto"] = port.proto
			oa["ports"] << p
		}
		return oa
	end # def
	
	def to_json
		return to_object_array.to_json
	end # def
	
	def parse(asset)
		if asset["ip"].nil? 
			return "ERR|No IP address"
		end
		begin
			ipaddr = IPAddr.new asset["ip"]
		rescue
			return "ERR|Incorrect IP address:#{asset["ip"]}"
		end
		@ip = asset["ip"]

		if asset["mac"].nil? 
			return "ERR|No MAC address"
		end
		@mac = asset["mac"]

		if asset["firstSeen"].nil? 
			return "ERR|No firstSeen"
		end
		@firstSeen = asset["firstSeen"]
		
		if asset["lastSeen"].nil? 
			return "ERR|No lastSeen"
		end
		@lastSeen = asset["lastSeen"]
		return "OK"
	end #def
	
	def ip # getter
		@ip
	end #def
	def ip=(ip) # setter
		@ip = ip
	end #def

	def mac # getter
		@mac
	end #def
	def mac=(mac) # setter
		@mac = mac
	end #def

	def firstSeen # getter
		@firstSeen
	end #def
	def firstSeen=(firstSeen) # setter
		@firstSeen = firstSeen
	end #def

	def lastSeen # getter
		@lastSeen
	end #def
	def lastSeen=(lastSeen) # setter
		@lastSeen = lastSeen
	end #def
	
	def ports # getter
		@ports
	end #def
	def ports=(ports) # setter
		@ports = ports
	end #def
end # class


class IPAMDB
	def initialize(dbpath)
# puts "new IPAMDB(#{dbpath})"
		@db = SQLite3::Database.new(dbpath)
		sqlCREATE
	end
	
	def sqlCREATE()
# puts "sqlCREATE"
	rows = @db.execute <<-SQL 
			CREATE TABLE IF NOT EXISTS asset 
			(
				ip varchar(32),
				mac varchar(32),
				firstSeen int,
				lastSeen int,
				active int,
				PRIMARY KEY (ip)
			);
        SQL
	rows = @db.execute <<-SQL 
			CREATE TABLE IF NOT EXISTS port 
			(
				ip varchar(32),
				proto varchar(3),
				port int,
				status varchar(6),
				firstSeen int,
				lastSeen int,
				PRIMARY KEY (ip, proto, port)
			);
        SQL
	rows = @db.execute <<-SQL 
			CREATE TABLE IF NOT EXISTS assetOS
			(
				ip varchar(32),
				mac varchar(32),
				osinfo text,
				firstSeen int,
				lastSeen int,
				PRIMARY KEY (ip, mac)
			);
        SQL

	end

	def sqlINSERT(ipa)
		@@logger.debug "SQL.INSERT #{ipa.to_object_array.to_json}"
		rows = @db.execute("INSERT INTO asset (ip, mac, firstSeen, lastSeen, active) VALUES(?, ?, ?, ?, 1)", [ipa.ip, ipa.mac, ipa.firstSeen, ipa.lastSeen])
	end #def

	def sqlUPDATE(ipa)
		@@logger.debug "SQL.UPDATE #{ipa.to_object_array.to_json}"
		rows = @db.execute("UPDATE asset SET firstSeen = ?, lastSeen = ? WHERE ip = ? AND mac = ?", [ipa.firstSeen, ipa.lastSeen, ipa.ip, ipa.mac])
	end #def

	def sqlUPDATEmac(ipa)
		@@logger.debug "SQL.UPDATE MAC #{ipa.to_object_array.to_json}"
		rows = @db.execute("UPDATE asset SET active = 0 WHERE ip = ? AND mac = ?", [ipa.ip, ipa.mac])
#		sqlINSERT(ipa)
	end #def

	def sqlSELECT()
		rows = @db.execute("SELECT ip, mac, firstSeen, lastSeen FROM asset WHERE active = 1 ORDER BY ip ")
		return rows
	end #def
	
	def sqlARCHIVE()
	end
	
	def sqlNewPresence()
	end

	
	def updatePort(ip, proto, portNo, portStatus, time)
#		rows = @db.execute("SELECT ip, mac, firstSeen, lastSeen FROM asset WHERE active = 1 ORDER BY ip ")
		rs = @db.execute("SELECT status, firstSeen, lastSeen FROM port WHERE ip = ? AND proto = ? AND port = ?", [ip, proto, portNo])
# 		puts rs.inspect
		if rs.empty?
			# insert
			rows = @db.execute("INSERT INTO port (ip, proto, port, status, firstSeen, lastSeen) VALUES(?, ?, ?, ?, ?, ?)", [ip, proto, portNo, portStatus, time, time])
			return "INSERT"
		else
			# update
			row = rs # rs.next
			oldStatus = row[0][0] # ["status"]
			
			if oldStatus != portStatus
				rows = @db.execute("UPDATE port SET lastSeen = ?, status = ? WHERE ip = ? AND proto = ? AND port = ?", [time, portStatus, ip, proto, portNo])
				return "UPDATE STATUS"								
			else
				rows = @db.execute("UPDATE port SET lastSeen = ? WHERE ip = ? AND proto = ? AND port = ?", [time, ip, proto, portNo])
				return "UPDATE"
			end
		end
	end # def
	
	def updateOS(ip, os, time)
		rs = @db.execute("SELECT osinfo, firstSeen, lastSeen FROM assetOS WHERE ip = ? ", [ip])
		if rs.empty?
			# insert
			rows = @db.execute("INSERT INTO assetOS (ip, osinfo, firstSeen, lastSeen) VALUES(?, ?, ?, ?, ?, ?)", [ip, os.to_s, time, time])
			return "INSERT"
		else
			# update
			oldInfo = row[0][0] # ["osinfo"]
			if oldInfo != os.to_s
				rows = @db.execute("UPDATE assetOS lastSeen = ? WHERE ip = ?", [time, ip])
				return "SAME"
			else
				rows = @db.execute("UPDATE assetOS osinfo = ?, firstSeen = ?, lastSeen = ? WHERE ip = ?", [os.to_s, time, time, ip])
				return "CHG"
			end
			
		end # if

	end # def

	
	def sqlSELECTports(ip)
		rows = @db.execute("SELECT port, proto, status  FROM port WHERE ip = ?", [ip])
		return rows
	end #def

	private

	
end # class

# class DnsModuleServer < TcpMultiportServerWrapper #TcpServerWrapper
class IPAMServer < TcpMultiportServerWrapper # < SingletonServer
#  include Singleton

	def initialize(roPort, rwPort, adminPort)
		super(roPort, rwPort, adminPort)
		@@logger.debug "IPAMServer.initialize "

	    @mutex  = Mutex.new

		mapRO = {}
		mapRO["select"] = lambda {|cmd| read cmd}
		mapRO["info"] = lambda {|cmd| inforo cmd}
		
		mapRW = {}
		mapRW["select"] = lambda {|cmd| read cmd}
		mapRW["new"] 	= lambda {|cmd| insert cmd}
		mapRW["insert"] = lambda {|cmd| insert cmd}
		mapRW["update"] = lambda {|cmd| update cmd}
		mapRW["portscan"] = lambda {|cmd| portscan cmd}
		mapRW["info"] = lambda {|cmd| inforw cmd}

		mapAdmin = {}
		mapAdmin["select"] = lambda {|cmd| read cmd}
		mapAdmin["rotate"] = lambda {|cmd| adminRotate cmd}
		mapAdmin["shutdown"] = lambda {|cmd| adminShutdown cmd}
		mapAdmin["info"] = lambda {|cmd| infoadmin cmd}

		@map = {}
		@map["read-only"] = mapRO
		@map["read-write"] = mapRW
		@map["admin"] = mapAdmin

		debug "IPAMServer:map[#{@map.inspect}]]"

		@assets = {}
		@ipamdb = IPAMDB.new("#{DBFILE}") # ("asset.sqlite3")
		with_mutex { 
			rows = @ipamdb.sqlSELECT() 
			
			rows.each { |row|
					ipa = IPAsset.new
					ipa.fromDBrow(row)
					
					ports = []
					prows = @ipamdb.sqlSELECTports(ipa.ip)
					prows.each { | prow |
						port = IPAssetPort.new(prow[0], prow[1], prow[2])
						ports << port
					}
					ipa.ports = ports
# puts ipa.inspect
					@assets[ipa.ip] = ipa

			}
		}
		@@logger.debug "IPAMServer.initialize loaded [#{@assets.size}] assets "
	end





#	def processJsonCommandRole(line, connID, mode)
#	end # processJsonCommandRole

	
	def processLineCommand(line, connID, role)
#	def processJsonCommand(line, connID, role)
		debug "processLineCommand:role[#{role}] line[#{line}]"
		map = @map[role]
		if line.start_with?("info")
			action = "info"
		else
			begin
				cmd = JSON.parse(line)
				action = cmd["action"]
			rescue JSON::ParserError
				@@logger.debug "JSON error parsing [#{line.chomp}]"
				return ErrorMessage("JSON error #{line.chomp}").to_json
				#"ERR|JSON error #{line.chomp}"			
			end
			@@logger.debug "Conn[#{connID}] Action:#{cmd["action"]}"
		end


# puts map[cmd["action"]].inspect
		if map.key?(action) 
			resp = map[action].call(cmd)
		debug "processLineCommand:resp[#{resp.inspect}]"

		else
			resp = ErrorMessage("unknown command #{line.chomp}").to_json
		end
		@@logger.debug "Conn[#{connID}] Response:#{resp}"

		return resp.to_json
	end #def
	
	private

	def adminShutdown(cmd)
		oResp = {}
		oResp["status"] = "OK"
		raise SystemExit
	end # def 
	
	def adminRotate(cmd)
		# TODO : change to rotate to a backup dir instead???
		oResp = {}
		oResp["status"] = "OK"
		with_mutex { 
			dt = Time.now.strftime("%Y%m%d-%H%M%S")
			if File.file?(NOTIFYNEWFILE)
				File.rename(NOTIFYNEWFILE, "#{NOTIFYNEWFILE}.#{dt}")
			end
			if File.file?(NOTIFYCHGFILE)
				File.rename(NOTIFYCHGFILE, "#{NOTIFYCHGFILE}.#{dt}")
			end
		}
		return oResp # resp   		
	end # def admin
	
	def read(cmd)
		oResp = {}
		oResp["status"] = "OK"
		resp = ""
		debug "read 1"
		with_mutex { 
			debug "read 2"
			if cmd.key?("ip")
				debug "read 3"
				if @assets.key?(cmd["ip"])			
					oResp["count"] = 1
					oResp["asset"] = @assets[cmd["ip"]].to_object_array
#					resp = "OK|ONE {\"asset\":#{@assets[cmd["ip"]].to_object_array.to_json}}" # . 
				else
					resp = "ERR|unknown IP [#{cmd["ip"]}]"			
#				oResp = ErrorMessage("unknown IP [#{cmd["ip"]}]").to_json

				end
			else
				debug "read 4"
				# select all
				aa = []
				@assets.each { |ip,asset|
					aa << asset.to_object_array
				}
#				resp = "OK|ALL {\"assets\":#{aa.to_json}}" # . 
				oResp["count"] = aa.length
				oResp["assets"] = aa
			end
		}
		debug "read 5"
		return oResp # resp   
	end #def
	
	def insert(cmd)
		return updateInsert(cmd, "insert")
	end #def
		
	def update(cmd)
		return updateInsert(cmd, "update")
	end #def	

=begin
	def self.read(cmd)
		puts "debug:self.read 1"
		return instance.read(cmd)
	end #def

	def self.insert(cmd)
		return instance.insert(cmd)
	end #def

	def self.update(cmd)
		puts "debug:self.update 1"
		return instance.update(cmd)
	end #def
=end
	def debug(str)
#  		puts "debug:#{str}"
	end 

	def with_mutex
		debug "with_mutex 1"
   		@mutex.synchronize { yield }
		debug "with_mutex 2"
	end
  
  	def ErrorMessage(errMsg) 
		oResp = {}
		oResp["status"] = "ERR"
		oResp["error"]  = errMsg
		return oResp
	end # def
	
	def info(role)
		methods = []
		debug "IPAMServer:info:map[#{@map.inspect}]]"
		map = @map[role]
		if map.nil?
			@@logger.error "No methods for [#{role}]"
		else
			map.each_key { |key|
				methods << key
			}
		end
		oResp = {}
		oResp["status"] = "OK"
		oResp["server"] = "IPAM"
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
	

	def portscan(cmd)
		oResp = {}
		oResp["status"] = "OK"
		nbPorts = 1
		with_mutex { 
			if !cmd["asset"].nil? 
				if !cmd["asset"]["ip"].nil? 
					ip = cmd["asset"]["ip"]
					if !cmd["asset"]["ports"].nil?
						cmd["asset"]["ports"].each { | port |
							#ports.each { |portNo, port|
							proto = port["proto"]
							portNo = port["port"]
								nbPorts = nbPorts + 1
								resp = @ipamdb.updatePort(ip, proto, portNo, port["status"], cmd["time"])
								case resp
								when "INSERT"
								when "UPDATE"
								when "UPDATE STATUS"
									# TODO : update
								end # case
							#}
						}
					end
					if !cmd["asset"]["os"].nil?
						resp = @ipamdb.updateOSt(ip, cmd["asset"]["os"], cmd["time"])
						case resp
							when "CHG"
								#
							onChg(cmd["asset"])
						end # case
					end
				end
			end
			oResp["ports"] = {}
			oResp["ports"]["count"] = nbPorts
			oResp["os"] = ""
		}
		return oResp
	end 

	def updateInsert(cmd, expected)
		oResp = {}
		oResp["status"] = "OK"
		debug "#{expected} 1"
		with_mutex { 
			debug "#{expected} 2"
			if !cmd["asset"].nil? 
				debug "#{expected} 2a"
				ipa = IPAsset.new
				resp = ipa.parse(cmd["asset"]) 
				debug "#{expected} 2b: #{resp}"
				if resp == "OK"
					debug "#{expected} 2c"
					if @assets.key?(ipa.ip)
						# key is present, this is an update
						if expected != "update"
							@@logger.warn "insert is really update [#{ipa.to_object_array.to_json}]"
						end
						debug "#{expected} 2d"
						# validate MAC
						if @assets[ipa.ip].mac == ipa.mac
							debug "#{expected} 2d-1"
							diffTime = ipa.lastSeen - @assets[ipa.ip].lastSeen
							debug "#{expected} 2d-2"
			debug "update 2d-3"
							if diffTime > @@secondsInactive
puts "*** TODO: too long without presence #{diffTime} seconds for #{ipa.ip}"
								debug "#{expected} 2d-3"
							end
							debug "#{expected} 2d-4"

							@assets[ipa.ip].lastSeen = ipa.lastSeen
							debug "#{expected} 2d-5"

							# resp = "OK|update #{@assets[ipa.ip].to_object_array.to_json}" # . cmd["asset"]
							oResp["action"] = "update"
							oResp["asset"] = @assets[ipa.ip].to_object_array
							debug "#{expected} 2d-6"
							@ipamdb.sqlUPDATE(ipa) # TODO
							debug "#{expected} 2d-7"							
						else
							oResp["status"] = "CHG"
							oResp["action"] = "change"
							oResp["asset"] = @assets[ipa.ip].to_object_array
							# resp = "CHG|mac change #{@assets[ipa.ip].to_object_array.to_json}" # . cmd["asset"]
							@ipamdb.sqlUPDATEmac(ipa) # TODO # should generate a alarm or message
#							appendToFile(NOTIFYCHGFILE, "#{ipa.to_object_array.to_json}\n")
							onChg(ipa)
						end
					else
						debug "#{expected} 2e"		
						# key is NOT present, this is an insert
						if expected != "insert"
							@@logger.warn "update is really insert [#{ipa.to_object_array.to_json}]"
						end
						@assets[ipa.ip] = ipa
						debug "#{expected} 2f"	
						@@logger.debug "New IP on network #{ipa.to_object_array.to_json}"
# puts "*** TODO: New IP on network #{ipa.to_object_array.to_json}"

						@ipamdb.sqlINSERT(ipa)
						oResp["action"] = "insert"
						oResp["asset"] = ipa.to_object_array

						debug "#{expected} 2g"	
#						File.write(NOTIFYNEWFILE, ipa.to_json + "\n", File.size(NOTIFYNEWFILE), mode: 'a')
						# resp = "OK|insert #{ipa.to_object_array.to_json}" # . cmd["asset"]
#						appendToFile(NOTIFYNEWFILE, "#{ipa.to_object_array.to_json}\n")
						onNew(ipa)
#						open(NOTIFYNEWFILE, 'a') { |f|
#							f << "#{ipa.to_object_array.to_json}\n"
#							f.close
#						} # open file

						debug "#{expected} 2h"	
					end
				end
			end
			debug "#{expected} 3"	
		} # with_mutex { 
		debug "#{expected} 3"	
		return oResp # resp   
	end #def

	def appendToFile(filename, txt)
		open(filename, 'a') { |f|
			f << txt
			f.close
		} # open file
	end # def appendToFile

	def onNew(ipa)
		@@logger.debug "onNew::#{ipa.to_object_array.to_json} "
		appendToFile(NOTIFYNEWFILE, "#{ipa.to_object_array.to_json}\n")
#		@@logger.debug "onNew::2 "
#		@@logger.debug "onNew::#{ipa.to_object_array["ip"]} "
		ip = ipa.to_object_array["ip"]		
		filepath = "#{PATHNEWCHGFOLDER}/new/#{ip}"
		@@logger.debug "onNew::Creating New File #{filepath} "

		File.open(filepath, "ab", FILE_PERMISSION) do |f|
			f.write(ip)
		end
	end

	def onChg(ipa)
		@@logger.debug "onChg::#{ipa.to_object_array.to_json} "
		appendToFile(NOTIFYCHGFILE, "#{ipa.to_object_array.to_json}\n")

		ip = ipa.to_object_array["ip"]		
		filepath = "#{PATHNEWCHGFOLDER}/chg/#{ip}"
		File.open(filepath, "ab", FILE_PERMISSION) do |f|
			f.write(ip)
		end
	end

	
end # class



# s = IpamServer.new(1234, 1235, 1236)
@@logger.debug "ipam.rb ipamserver main "
puts "STDOUT ipam.rb ipamserver main "
s = IPAMServer.new(TCProPort, TCPrwPort, TCPadminPort)
s.waitForConnections
puts "ipam.rb - Stopped"



=begin
=end
