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
# require 'Zlib::GzipReader'
require 'zlib'
require 'sqlite3'
require 'fileutils'
require_relative 'MostUsedHash'

class DnsEntry
	def initialize(domain, ip, type)
		@domain = domain
		@ip = ip
		@type = type
	end
	
	def to_object_array
		oa = {}
		oa["domain"] = @domain
		oa["type"] = @type
		oa["ip"] = @ip
		return oa
	end # def
end # class DnsEntry

class DnsEntriesFolder
	def initialize(baseFolder)
		@baseFolder = baseFolder
		if !@baseFolder.end_with?
			@baseFolder = @baseFolder + File::SEPARATOR
		end
	end

	def addQuery(from, domain, type) 
	end # addQuery

	def addReply(ip, domain, verb = 'A') 
		ipFolder = ip.gsub! ".", File::SEPARATOR
		path = "#{@baseFolder}#{ipFolder}#{File::SEPARATOR}" ##{verb}#{File::SEPARATOR}
# puts path
		dirname = File.dirname("#{path}#{verb}#{File::SEPARATOR}")
		unless File.directory?(dirname)
		  FileUtils.mkdir_p(dirname)
		  FileUtils.mkdir_p(dirname)
		end
		filePath = "#{path}#{verb}-#{domain}"
# puts filePath
		open(filePath, 'a') do |f|
		  f.puts "#{verb};#{ip};#{domain}"
		end
	end # addReply

	private
end

class DnsEntriesDB
	def initialize(dbFilePath)
		@db = ::SQLite3::Database.open dbFilePath
		sqlCREATE
	end
	
	def self.finalize(bar)
#    proc {  puts "DESTROY OBJECT #{bar}" }
		proc {  @db.close }
	end

	def close()
		@db.close
	end
	
	def addQuery(from, domain, type) 
	end # addQuery

	def addReply(ip, domain, verb = 'A') 
		@@logger.debug "DnsEntriesDB:addReply[ip=#{ip}], domain=#{domain}, verb=#{verb}]"
		if sqlExists(domain, ip, verb) == 0
			sqlINSERT(domain, ip, verb)
		else
			sqlUPDATE(domain, ip, verb)
		end
	end # addReply
	
	
	def getByIP(ip)
		rows = @db.execute("SELECT type, domain FROM dnsEntries WHERE ipv4 = ? ", [ip])
		nb = 0
		a = []
		rows.each do |row|
			a[nb] = DnsEntry.new(row[1], ip, row[0])
			# {"ip" => ip, "type" => row[0], "domain" => row[1]}
			nb = nb + 1
		end
		return a
	end # def

	def getByDomain(domain)
		rows = @db.execute("SELECT type, ipv4 FROM dnsEntries WHERE domain = ? ", [domain])
		nb = 0
		a = []
		rows.each do |row|
			a[nb] = DnsEntry.new(domain, row[1], row[0])
			# {"ip" => ip, "type" => row[0], "domain" => row[1]}
			nb = nb + 1
		end
		return a
	end # def
	private
	
	def sqlCREATE()
	rows = @db.execute <<-SQL 
			CREATE TABLE IF NOT EXISTS dnsEntries 
			(
				ipv4 varchar(20),
				domain varchar(200),
				type varchar(10),
				dateAdded int,
				dateLastSeen int,
  				PRIMARY KEY (ipv4, domain, type)

			);
        SQL
	end
	
	def sqlINSERT(domain, ip, type)
#		@@logger.debug "sqlINSERT"
		rows = @db.execute("INSERT INTO dnsEntries (ipv4, domain, type, dateAdded, dateLastSeen) VALUES(?, ?, ?, ?, ?)", 
			[ip, domain, type, Time.now.to_i, Time.now.to_i])

	end #def

	def sqlUPDATE(domain, ip, type)
#		@@logger.debug "sqlUPDATE"
		rows = @db.execute("UPDATE dnsEntries SET dateAdded = ?, dateLastSeen = ? WHERE ipv4 = ? AND domain = ? AND type = ?",
			[Time.now.to_i, Time.now.to_i, p, domain, type])
	end #def


	
	
	def sqlExists(domain, ip, type)
		rows = @db.execute("SELECT count(*) FROM dnsEntries WHERE ipv4 = ? AND domain = ? AND type = ?",
			[ip, domain, type])

		if rows.nil?
			return 0
		end
		if rows.length == 0 
			return 0
		end
		row = rows[0]
		if row[0].nil? || row[0] == ""
			return 0
		end
		
		return row[0] # count
	end #def
	
end # class DnsEntriesDB

class DnsEntries
	def initialize
		log = {}
		@reverse = MostUsedHash.new(log, 102400)
#		@db = DnsEntriesDB.new("dns.sqlite3")
		@db = DnsEntriesDB.new("#{DBFILE}")
		# @folder = DnsEntriesFolder.new("dns")
		# TODO
	end # initialize
	
	def reverseDNS(ip)
		if @reverse.hasKey(ip)
			return @reverse.getItem(ip)
		end
		# not in cache, add to cache
		a = @db.getByIP(ip)
		@reverse.addItem(ip, a)

		return a
	end

	def DNS(domain)
		#if @reverse.hasKey(ip)
		#	return @reverse.getItem(ip)
		#end
		# not in cache, add to cache
		a = @db.getByDomain(domain)
		#@reverse.addItem(ip, a)
		return a
	end


	def addQuery(from, domain, type) 
#		e = DnsEntry.new(domain, ip)
		if !@db.nil? 
			@db.addQuery(from, domain, type) 
		end
		if !@folder.nil? 
			@folder.addQuery(from, domain, type) 
		end
	end # addReply

	def addReply(ip, domain, verb = 'A') 
		@@logger.debug "DnsEntries:addReply[ip=#{ip}], domain=#{domain}, verb=#{verb}]"
#	puts "#{domain}=#{ip}"
		e = DnsEntry.new(domain, ip, verb)
		if !@db.nil? 
			@db.addReply(ip, domain) 
		end
		if !@folder.nil? 
			@folder.addReply(ip, domain) 
		end
		if @reverse.hasKey(ip)
			a = @reverse.getItem(ip)
			a[a.length] = e
			@reverse.replaceItem(ip, a)
		else
			a = []
			a[0] = e
			@reverse.addItem(ip, a)
		end
	end # addReply

#Jul 25 10:53:49 dnsmasq[1]: forwarded links.services.disqus.com to 172.21.0.2
def parseLine(logline)
				action = "disregard" # disregard all other
				if (logline =~ /^query/) #query[A] google.com from 172.17.0.1
					action = "query"
					domain = logline[/(?<action>([a-zA-Z])+)(\[)(?<type>([a-zA-Z])+)(\])(\s)(?<domain>(.)+)(\s)(?<verb>(.)+)(\s)(?<result>(.+))\Z/, "domain"] 
					ip = logline[/(?<action>([a-zA-Z])+)(\[)(?<type>([a-zA-Z])+)(\])(\s)(?<domain>(.)+)(\s)(?<verb>(.)+)(\s)(?<result>(.+))\Z/, "result"] 
					type = logline[/(?<action>([a-zA-Z])+)(\[)(?<type>([a-zA-Z])+)(\])(\s)(?<domain>(.)+)(\s)(?<verb>(.)+)(\s)(?<result>(.+))\Z/, "type"] 
					if (domain =~ /(.*)\.internal\Z/) 
					else
						addQuery(type, ip, domain) 
#							toDnsModule(record)
						
					end
					# puts "Query ", record["domain"], time, time.to_i
				end

#there can be multiple reply replies
#reply google.com is 172.217.13.110
#puts "in reply"
				if (logline =~ /^reply/)
#	puts logline
					action = "reply"
					ip =     logline[/(?<action>([a-zA-Z0-9.\[\]])+)(\s)(?<domain>([a-zA-Z0-9.])+)(\s)(?<verb>([a-zA-Z0-9.])+)(\s)(?<result>(.)+)\Z/, "result"] 
					domain = logline[/(?<action>([a-zA-Z0-9.\[\]])+)(\s)(?<domain>([a-zA-Z0-9.])+)(\s)(?<verb>([a-zA-Z0-9.])+)(\s)(?<result>(.)+)\Z/, "domain"] 
					verb   = logline[/(?<action>([a-zA-Z0-9.\[\]])+)(\s)(?<domain>([a-zA-Z0-9.])+)(\s)(?<verb>([a-zA-Z0-9.])+)(\s)(?<result>(.)+)\Z/, "verb"] 
					if ip == "<CNAME>"
#						p "Domain is CNAME", domain:record["domain"], ip:record["ip"]
					elsif ip == "NXDOMAIN"
					elsif ip == ""
					elsif ip.nil?
					elsif (ip.include?(":"))
						# ipv6 - disregard
					else
						addReply(ip, domain) 
					
#						addDomainIP(record["domain"], record["ip"], time)
#							toDnsModule(record)
					end
				end

#there can be multiple cached replies
#cached google.com is 172.217.13.110
				if (logline =~ /^cached/)
					action = "cached"
					ip = logline[/(?<action>([a-zA-Z0-9.\[\]])+)(\s)(?<domain>([a-zA-Z0-9.])+)(\s)(?<verb>([a-zA-Z0-9.])+)(\s)(?<result>([a-zA-Z0-9.])+)\Z/, "result"]
					domain = logline[/(?<action>([a-zA-Z0-9.\[\]])+)(\s)(?<domain>([a-zA-Z0-9.])+)(\s)(?<verb>([a-zA-Z0-9.])+)(\s)(?<result>([a-zA-Z0-9.])+)\Z/, "domain"] 
					verb = logline[/(?<action>([a-zA-Z0-9.\[\]])+)(\s)(?<domain>([a-zA-Z0-9.])+)(\s)(?<verb>([a-zA-Z0-9.])+)(\s)(?<result>([a-zA-Z0-9.])+)\Z/, "verb"] 
#					cachedDomain(record["domain"], record["ip"], time)
#							toDnsModule(record)
				end
end #parseLine

end # class

=begin
def loadGzFile(fileName, ez)
	infile = open(fileName)
	gz = Zlib::GzipReader.new(infile)
	gz.each_line do |line|
	#  puts line
		ez.parseLine(line[28..-1])
	end
end

ez = DnsEntries.new

# loadGzFile("dnslogs.gz", ez)

a = ez.reverseDNS("17.178.96.59")
# a = ez.reverseDNS("0.0.0.0")
# puts a.inspect
=end