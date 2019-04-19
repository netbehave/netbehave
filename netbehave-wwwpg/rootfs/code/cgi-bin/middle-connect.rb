#!/usr/bin/ruby
require "socket"
require "json/pure"

host = "localhost"
TCPport = 5000

# {"action":"select"}
def createQuery() # ip, domain, type
	oq = {}
	oq["action"] =  "open"
	return oq
end

session = TCPSocket.open("#{host}", TCPport)

query = createQuery()
# STDERR.puts "query:\t\t[#{query.to_json}]"
# STDERR.puts "r:\t\t[#{query.to_json}]"

session.puts query.to_json
line = session.gets

cmd = JSON.parse(line)

print "HTTP/1.1 200\r\n" # 1
print "Content-Type: text/json\r\n" # 2
print "\r\n" # 3
#puts "#{line}"
puts "#{cmd.to_json}"