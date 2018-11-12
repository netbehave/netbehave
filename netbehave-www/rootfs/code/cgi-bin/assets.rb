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
require "socket"
require "json/pure"

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

print "HTTP/1.1 200\r\n" # 1
print "Content-Type: text/json\r\n" # 2
print "\r\n" # 3
# puts "response:\t[#{line}]"
puts "#{line}"