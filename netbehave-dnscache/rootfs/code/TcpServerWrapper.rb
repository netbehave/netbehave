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
# TcpServerWrapper.rb
class TcpMultiportServerWrapper
	def initialize(roPort, rwPort, adminPort)
		@roPort = roPort
		@rwPort = rwPort
		@adminPort = adminPort
	end # def new(roPort)
	
	def processLineCommand(line, connID, role)
#						resp = @ipam.processJsonCommand(line)
		return ""
	end # def

	def waitForConnections
		puts "Main thread: #{Thread.current.object_id}"
		begin
				roTH = Thread.new { waitForConnectionToServer(@roPort, "read-only") } 
				rwTH = Thread.new { waitForConnectionToServer(@rwPort, "read-write") } 
				#main thread is admin
				waitForConnectionToServer(@adminPort, "admin")
		rescue Errno::ECONNRESET, Errno::EPIPE => e
#			@@logger.error e.message
			STDERR.puts e.message
			retry
		rescue SystemExit, Interrupt
#			@@logger.info "Finalizing Servers"
			puts "Finalizing Servers"
		end   
#		@roServer.close
#		@rwServer.close
#		@adminServer.close
	end # def
	
	private
	def waitForConnectionToServer(port, stype)
		@@logger.info("Open port tcp/#{port} for #{stype} connections")
		puts "Open port tcp/#{port} for #{stype} connections"
		server = TCPServer.new(port)
		@@logger.info "#{stype} server thread: #{Thread.current.object_id}"
		puts "#{stype} server thread start: #{Thread.current.object_id}"
		opened = 0
		closed = 0
		begin
				@@logger.info "#{stype} Waiting for connections\n"
				puts "#{stype} Waiting for connections\n"
			loop do
				Thread.fork(server.accept) do |connection| 
					sock_domain, remote_port, remote_hostname, remote_ip = connection.peeraddr
					opened = opened + 1
					cur = opened
					@@logger.info "#{stype} New connection #{cur} from #{remote_ip}:#{remote_port} \n" # https://stackoverflow.com/questions/13846984/ruby-tcpserver-to-get-client-ip-address
					puts "#{stype} New connection #{cur} from #{remote_ip}:#{remote_port} \n" # https://stackoverflow.com/questions/13846984/ruby-tcpserver-to-get-client-ip-address
					while line = connection.gets
						break if line =~ /quit/
						@@logger.info "Conn[#{stype}/#{cur}] CMD[#{line.chomp}]"
						puts "Conn[#{stype}/#{cur}] CMD[#{line.chomp}]"
						resp = processLineCommand(line, cur, stype) # @ipam.processJsonCommand(line)
#						connection.puts "> #{resp}\n"
						connection.puts "#{resp}\n"
					end # while
					connection.puts "#{stype} Closing the connection #{cur}. Bye!\n"	        
					connection.close
					closed = closed + 1
				end # do ||
			end # loop do
		rescue Errno::ECONNRESET, Errno::EPIPE => e
#			@@logger.error e.message
			STDERR.puts e.message
			retry
		end   
		server.close
		@@logger.info "#{stype} server thread finish: #{Thread.current.object_id}"
		puts "#{stype} server thread finish: #{Thread.current.object_id}"
	end # def
	

end # class
