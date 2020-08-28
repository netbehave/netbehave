# initialize the PG NetBehave Database
require 'pg'
require 'csv'
require 'logger'
# require 'fileutils'

# variable initialization
@dbpass = ENV["POSTGRES_PASSWORD"]
@dbname =  ENV["POSTGRES_DB"]
@dbhost = ENV["POSTGRES_HOST"]
# @dbuser = "postgres"
@dbuser = ENV["POSTGRES_USER"]
@db = nil

logpath = ENV["LOGPATH"]

system 'mkdir', '-p', logpath # worse version: system 'mkdir -p "foo/bar"'

if !logpath.end_with?('/')
	logpath = "#{logpath}/"
end

LOGFILE = "#{logpath}initdb.log"
@logger = Logger.new("#{LOGFILE}") # File.new("#{LOGFILE}")
@logger.progname = "initdb.rb"

def sqlCREATE(filePath)
	begin
		query = IO.read(filePath)
		rows = @db.exec(query) 
	rescue => e
		STDERR.puts "Error in sqlCREATE(#{filePath}):#{e.to_s}"
		debug("Error in sqlCREATE(#{filePath}):#{e.to_s}")
	end

end


def dbOpen(p_dbname, p_dbuser,  p_dbpass, p_dbhost)
	if @db.nil?
		begin
			@db = PG.connect( dbname: p_dbname, user: p_dbuser,  password: p_dbpass, host: p_dbhost)
			sqlCREATE("/code/v2-base.sql")
			sqlCREATE("/code/v2-app-host.sql")
			sqlCREATE("/code/v2-net-ip.sql")
			sqlCREATE("/code/v2-service.sql")
			sqlCREATE("/code/v2-unknown.sql")
			sqlCREATE("/code/v2-flows.sql")
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
#	puts "*** initdb:#{str}"
	@logger.debug str
end

def main
	nbServices = 0
	debug("main:start")
	if dbOpen(@dbname, @dbuser, @dbpass, @dbhost)
		debug("main:services")
		rows = @db.exec("SELECT count(protoPort) as nb FROM service")
		rows.each do |row|
			# puts "#{row.to_s}"
			nbServices = row["nb"].to_i
		end
		debug("main:services count #{nbServices}")
		if nbServices <= 0
			debug("main:load services")
			CSV.foreach("/code/services.csv") do |row|
				protoPort = row[0]
				serviceName = row[1]
				serviceDescription = row[2]
				rows = @db.exec_params("INSERT INTO service (protoPort, serviceName, serviceDescription) VALUES($1, $2, $3)", [protoPort, serviceName, serviceDescription])
				nbServices = nbServices + 1
			end
			debug("main:load #{nbServices} services")
		end
	
=begin
		debug("main:acl")
		nbacl = 0
		rows = @db.exec("SELECT count(rulename) as nb FROM acl")
		rows.each do |row|
			# puts "#{row.to_s}"
			nbacl = row["nb"].to_i
		end
		debug("main:acl count #{nbacl}")
		if nbacl <= 0
			debug("main:add acl")
			rows = @db.exec_params("INSERT INTO acl (rulename, rulecsv) VALUES($1, $2)", ["ping", "protocol_name=ICMP"])
		end
		debug("main:nothing to do for acl")
=end
		dbClose()
	else
	end

	debug("main:end")
	return nbServices
end # main

nb = 0 
while nb == 0
	sleep 5
	nb = main
end
debug("init done")
