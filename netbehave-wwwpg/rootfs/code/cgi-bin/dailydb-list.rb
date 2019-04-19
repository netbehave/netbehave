#!/usr/bin/ruby
# require "sqlite3"
require "json/pure"
require 'pg'
require 'logger'

# variable initialization
@dbpass = ENV["POSTGRES_PASSWORD"]
@dbname =  ENV["POSTGRES_DB"]
@dbhost = ENV["POSTGRES_HOST"]
@dbuser = "postgres"
@db = nil

@logger = Logger.new STDERR
#@logger = Logger.new("/opt/netbehave/debug") # File.new("#{LOGFILE}")
#@logger.progname = "assets.rb"


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
files = []
# @assets[cmd["ip"]].to_object_array
if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
	debug("main:select")
	yyyymmdd = DateTime.now.strftime("%Y%m%d")
	query = "SELECT tablename FROM pg_tables where tablename like 'flow%'"  + " AND tablename <> 'flow" + yyyymmdd + "'"
			debug("#{query}")		
	rows = @db.exec(query)
	rows.each do |row|
		# puts "#{row.to_s}"
#		debug("#{row.to_s}")
#		nbServices = row["nb"].to_i

#		tablename = row["tablename"]

		fileinfo = {}
		fileinfo["tablename"] = row["tablename"]
		fileinfo["count"] = 0
		files << fileinfo
		oResp["count"] = oResp["count"] + 1
	end

	files.each do |file|
		query = "SELECT count(*) as nb FROM " + file["tablename"]
#			debug("#{query}")		
		rows = @db.exec(query)
		rows.each do |row|
#			debug("#{row.to_s}")		
			file["count"] = row["nb"]
		end
	end

end


oResp["files"] = files
line = oResp.to_json



print "HTTP/1.1 200\r\n" # 1
print "Content-Type: text/json\r\n" # 2
print "\r\n" # 3
# puts "response:\t[#{line}]"
puts "#{line}"