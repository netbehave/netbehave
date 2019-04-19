#!/usr/bin/ruby
require 'cgi'
#require "sqlite3"
#require "json/pure"
require 'pg'
require 'logger'
require 'tempfile'

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

cgi = CGI.new
tablename = cgi['tablename']

file = Tempfile.new(tablename)


csvstr = "srcip,dstip,proto,srcport,dstport,srcdomain,dstdomain,srcnetwork,dstnetwork,servicename,match,dateAdded,dateLastSeen,hits,bytes"
file.write(csvstr)
file.write "\n"


if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
	query = "SELECT srcip, dstip, proto, srcport, dstport, srcdomain, dstdomain, srcnetwork, dstnetwork, servicename, match, dateadded, datelastseen, hits, bytes FROM " + tablename
#	debug("#{query}")
	rows = @db.exec(query)
	rows.each do |row|
		# puts "#{row.to_s}"
		file.write '"' + row["srcip"] + '",'
		file.write '"' + row["dstip"] + '",'
		file.write '"' + row["proto"] + '",'
		file.write row["srcport"] + ","
		file.write row["dstport"] + ","
		file.write '"' + row["srcdomain"] + '",'
		file.write '"' + row["dstdomain"] + '",'
		file.write '"' + row["srcnetwork"] + '",'
		file.write '"' + row["dstnetwork"] + '",'
		file.write '"' + row["servicename"] + '",'
		file.write '"' + row["match"] + '",'
	
		if row["dateadded"].nil?
			file.write '"' + 'nil' + '",'
		else
			file.write '"' + row["dateadded"] + '",'
		end
		if row["datelastseen"].nil?
			file.write '"' + 'nil' + '",'
		else
			file.write '"' + row["datelastseen"] + '",'
		end
		
		file.write row["hits"] + ","
		file.write row["bytes"] 
		file.write "\n"
	end
end #if dbOpen

file.rewind

debug("filename=#{tablename}.csv")
CGI.new.out(
  "Content-Type" => 'text/csv',
  "content-disposition" => "attachment; filename=#{tablename}.csv"
) do
    file.read
end

file.close
file.unlink
# end