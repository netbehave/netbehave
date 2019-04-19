#!/usr/bin/ruby
#require "socket"
require "json/pure"
require 'pg'
require 'logger'

# variable initialization
@dbpass = ENV["POSTGRES_PASSWORD"]
@dbname =  ENV["POSTGRES_DB"]
@dbhost = ENV["POSTGRES_HOST"]
@dbuser = "postgres"
@db = nil

# @logger = Logger.new STDERR
@logger = Logger.new("/opt/netbehave/debug") # File.new("#{LOGFILE}")
@logger.progname = "assets.rb"


=begin
host = "netbehave-ipam"
TCPrwPort = 11001

# {"action":"select"}
def createQuery() # ip, domain, type
	oq = {}
	oq["action"] =  "select"
	return oq
end

session = TCPSocket.open("#{host}", TCPrwPort)

query = createQuery()
# STDERR.puts "query:\t\t[#{query.to_json}]"
# STDERR.puts "r:\t\t[#{query.to_json}]"

session.puts query.to_json
line = session.gets
=end

def dbOpen(p_dbname, p_dbuser,  p_dbpass, p_dbhost)
	if @db.nil?
		begin
			@db = PG.connect( dbname: p_dbname, user: p_dbuser,  password: p_dbpass, host: p_dbhost)
			return true
		rescue => e
	debug("Error in dbOpen:#{e.to_s}")
			return false
		end
	end
	return true
end

def dbClose
	if !@db.nil?
		@db.close
		@db = nil
	end
end 

def debug(str)
	if !@logger.nil?
		@logger.debug str
	else
		puts "*** initdb:#{str}"
	end
end

oResp = {}
oResp["count"] = 0
oResp["status"] = "OK"
oResp["assets"] = []
# @assets[cmd["ip"]].to_object_array
if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
	debug("main:select")
	rows = @db.exec("SELECT ip, mac, firstseen, lastseen FROM ipam_asset WHERE active = 1 ORDER BY ip")
	rows.each do |row|
		# puts "#{row.to_s}"
		debug("#{row.to_s}")
#		nbServices = row["nb"].to_i
		asset = {}
		asset["ip"] = row["ip"]
		asset["mac"] = row["mac"]
		asset["firstSeen"] = row["firstseen"]
		asset["lastSeen"] = row["lastseen"]
		asset["ports"] = []
		oResp["assets"] << asset
		oResp["count"] = oResp["count"] + 1
	end
end

line = oResp.to_json

print "HTTP/1.1 200\r\n" # 1
print "Content-Type: text/json\r\n" # 2
print "\r\n" # 3
# puts "response:\t[#{line}]"
puts "#{line}"