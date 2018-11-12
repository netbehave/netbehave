#!/usr/bin/ruby
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
require "sqlite3"
require "json/pure"

def getFlowCount(filePath)
	begin
		db = ::SQLite3::Database.open( filePath )
		count = 0
		rows = db.execute("select count(*) from flow")
		db.close
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
	rescue => e
		return "locked"
	end
end

now = DateTime.now
yyyymmdd = now.strftime("%Y-%m-%d")

# sqlite3 flows-2018-10-27.sqlite3 " select count(*) from flow;"
files = []
# query = "select count(*) from flow;"
folderPath = "/opt/netbehave/core/dailydb/"
Dir.entries(folderPath).sort.each { |filename|
		if filename.end_with?(".sqlite3")
			if filename.include?(yyyymmdd)
				count = "in process"
			else
				count = getFlowCount("#{folderPath}#{filename}")
			end if
			size = File.size("#{folderPath}#{filename}")
			files << {"filename":filename, "count":count, "size":size}
		end

	}

response = {"status":"OK", "files":files}


line = response.to_json

# STDERR.puts "query:\t\t[#{query.to_json}]"
# STDERR.puts "r:\t\t[#{query.to_json}]"


print "HTTP/1.1 200\r\n" # 1
print "Content-Type: text/json\r\n" # 2
print "\r\n" # 3
# puts "response:\t[#{line}]"
puts "#{line}"