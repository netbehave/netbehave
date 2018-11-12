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
require 'singleton'
require 'ipaddr'
require 'logger'

require_relative 'server' #.rb


dbpath =  ENV["DNSCACHEDATADIR"]
if dbpath.nil?
	dbpath = "/opt/netbehave/dnscache"
end

DBFILE="#{dbpath}/dns.db"

TCProPort = 10001
TCPrwPort = 10002
TCPadminPort = 10003

@@logger = Logger.new STDOUT
# Logger.new('/dev/null')
# 
# @@logger = Logger.new File.new("#{dbpath}/dnscache.log", 'a')
# @@logger = Logger.new LOGFILE
@@logger.progname = "dns.rb"
@@logger.debug "Test Log Writing"

# puts "This is Ruby from DNS!"
# STDERR.puts "This is Ruby in STDERR!"
STDOUT.puts "Starting DNS Cache"
s = DnsModuleServer.new(TCProPort, TCPrwPort, TCPadminPort)
s.waitForConnections
puts "DNS Cache - Stopped"

