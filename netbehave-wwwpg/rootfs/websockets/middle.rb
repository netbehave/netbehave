# Leveraged : https://github.com/imanel/websocket-eventmachine-server
# https://github.com/eventmachine/eventmachine
# Intermediary netbehave passthrough server (browser to core) running on wwww

require 'websocket-eventmachine-server'

require 'socket'      # Sockets are in standard library
#require 'sqlite3'
require 'json'
require 'singleton'
require 'ipaddr'
require 'logger'

# require_relative 'server' #.rb
searchPort = 5000
corePort = 6000

STDOUT.sync = true

@@host = "netbehave-www"
@@instructionFile = "/opt/netbehave/core/search"
# @@instructionFile = "./search"


class PassthroughTcpServer
	def initialize(searchPort, corePort)
		@lastSearchPort = searchPort + 1
		@lastCorePort = corePort + 1
#		@threadName = "[#{0}] Main Server"
		Thread.current["threadName"] = "[#{0}] Main Server"
	end

	def waitForConnectionToServer(port)
		debug("Open port tcp/#{port} - thread:#{Thread.current.object_id}")
		writeCmd("init", port)
		server = TCPServer.new(port)
		begin
		
			# Patch - start : unsure why first attempt at threading does not work...
#			start_threads
			@lastSearchPort = @lastSearchPort + 1
			@lastCorePort = @lastCorePort + 1
			# Patch - end

			loop do
				# Accept one connection at a time to kick of threads
				connection = server.accept
				# Get JSON based command on one line
				line = connection.gets 
				cmd = JSON.parse(line)
				action = cmd["action"]
				if action == "open"
					start_threads
					
					resp = Message("OK", "searchPort", @lastSearchPort)
					connection.puts "#{resp.to_json}\n"

					@lastSearchPort = @lastSearchPort + 1
					@lastCorePort = @lastCorePort + 1
				else
				end
				connection.close
			end # loop do
		rescue Errno::ECONNRESET, Errno::EPIPE => e
debug("Error: #{e.message}")
			@@logger.error e.message
			retry
		rescue SystemExit, Interrupt
debug("Exiting after user intervention")
		end # begin, rescue
		server.close
#		@@logger.info "#{@threadName} - Thread finish: #{Thread.current.object_id}"
		debug("Finishing: #{Thread.current.object_id}")
	end # def
	
	
	def start_threads
		searchPort = @lastSearchPort
		corePort = @lastCorePort
		queue = EM::Queue.new # 
		queueThread = EM::Queue.new # 


		start_websocket_thread(searchPort, corePort, queue, queueThread)
		queue_work2 = Proc.new do |data|
			debug(data)
#						ws.send(data)
#						EM.next_tick { queueThread.pop(&queue_work) }
		end
		queueThread.pop(&queue_work2)


		start_core_thread(corePort, queue, queueThread)

		queue_work1 = Proc.new do |data|
			debug(data)
#						ws.send(data)
#						EM.next_tick { queueThread.pop(&queue_work) }
		end
		queueThread.pop(&queue_work1)

	end
	
	def start_core_thread(corePort, queue, queueThread)
#		@queue = EM::Queue.new
#		@queue = Queue.new
		isParent = true
		corethread = Thread.new { 
			Thread.current['threadName'] = "[#{corePort}] Core Server"
			Thread.current["queue"] = queue
			debug("core/preparing to start new thread #{corePort}")
			writeCmd("open", corePort)
			debug("core/starting...")
			queueThread.push "... core thread ready [#{corePort}]"
			coreServerConnection(corePort) # , method(:onCoreServerMessage))
			# , cb)
			isParent = false
		}
		debug("core/isParent=#{isParent}")
		if !isParent
# debug("core/Child after threading")
			corethread.join
		else
# debug("core/Parent after threading")
			Thread.current["core"] = corethread
		end	
	end # def

	def start_websocket_thread(searchPort, corePort, queue, queueThread)
	
		isParent = true
		debug("ws/preparing to start new websocket thread #{searchPort},#{corePort}")

		
		wsthread = Thread.new { 
			Thread.current['threadName'] = "[#{searchPort}] WebSocket Server"
			Thread.current["queue"] = queue
			queueThread.push "... websocket thread ready [#{searchPort}]"
			passthrough(searchPort, corePort) 
			isParent = false
		}
# debug("ws/isParent=#{isParent}")
		if !isParent
# debug("ws/Child after threading")
			wsthread.join
		else
# debug("ws/Parent after threading")
		end
	end # def

	def coreServerConnection(corePort) # , callback)
		# @threadName 

		debug("before TCPServer.new")
		server = TCPServer.new(corePort)
		debug("Awaiting connection")

			loop do
		begin 
		connection = server.accept
		debug("Client connected")		
		
			while flowline = connection.gets
# debug("Received from core [#{flowline.strip}]")		
#			    @callback.call(flowline)
			queue = Thread.current["queue"]
			if queue.nil?
debug("Queue is nil")
			else
# debug("Queue is ok #{queue.inspect}")
debug("Queue #{Thread.current['queue']} push  #{flowline.strip}")
				Thread.current["queue"].push flowline.strip
				# flowline.strip
# debug("Queue is ok - after")
			end
#				Thread.current["queue"].push flowline.strip
# debug("Client After")		
			end # while
		
		debug("Finished loop")		
			connection.close
			server.close


		rescue Errno::ECONNRESET, Errno::EPIPE => e
		debug("Error #{e.message}")		
			@@logger.error e.message
			retry
		rescue SystemExit, Interrupt
			puts "Exiting core server connection"
		end # begin, rescue
			end # loop do
	end


	def passthrough(searchPort, corePort) # , curConn , local_host, remote_ip, remote_port, queries)
		# @threadName 
		# wait for search
				# sock_domain, remote_port, remote_hostname, remote_ip = connection.peeraddr
				# should be sent from cgi:
				# 	@headers: user-agent, sec-websocket-key
				# 	@path
				# to confirm identity
#		@queue = EM::Queue.new
		begin 
			EM.run do
				debug("Waiting for connections on #{searchPort} - thread:#{Thread.current.object_id}")
#				@@logger.info "[#{curConn}] WebSocket Thread - Waiting for connections on #{searchPort} - thread:#{Thread.current.object_id}"

				WebSocket::EventMachine::Server.start(:host => "0.0.0.0", :port => searchPort) do |ws|


					ws.onopen do | handshake |
debug("ws.onopen #{searchPort}")
						key = handshake.headers['sec-websocket-key']

debug("Queue #{Thread.current['queue']}")
						queue_work = Proc.new do |data|
debug("Popped [#{data.inspect}] ... Send")
							ws.send(data)
							EM.next_tick { Thread.current["queue"].pop(&queue_work) }
						end
						Thread.current["queue"].pop(&queue_work)
=begin
=end
debug("Client connected")
#						@@logger.info "[#{curConn}]  " 
#						ws.send "Hello Client!"
#						ws.send "binary data", :type => :binary
					end
					
					ws.onmessage do |msg, type|
debug("Received message: #{msg} #{type}")
#						@@logger.info "[#{curConn}]  "
#						ws.send msg, :type => type
						begin
							cmd = JSON.parse(msg)
							if cmd["action"] == "disconnect"
								writeCmd(cmd["action"], corePort)
								ws.close
							elsif cmd["action"] == "stop"
								writeCmd(cmd["action"], corePort)
							elsif cmd["action"] == "replaceQueries"
								writeCmd(cmd["action"], corePort, cmd["queries"])
							elsif cmd["action"] == "addQueries"
								writeCmd(cmd["action"], corePort, cmd["queries"])
							else
debug("unexpected command [#{msg}]")							
							end
						rescue JSON::ParserError
debug("JSON error on: [#{msg}]")
						end

					end

					ws.onclose do
debug("onclose. Client disconnected")
						writeCmd("stop", corePort)
						WebSocket::EventMachine::stop_event_loop
#						@@logger.info "[#{curConn}] Client disconnected"
debug("onclose. Client disconnected #2")
						ws = nil
					end

					ws.onerror do |error|
debug("Error occured: #{error}")
#						@@logger.info "[#{curConn}] "
					end

					ws.onping do |message|
debug("Ping received: #{message}")
#						@@logger.info "[#{curConn}] "
					end

					ws.onpong do |message|
debug("Pong received: #{message}")
#						@@logger.info "[#{curConn}] "
					end


				end # .start

			end # EM.run do
		rescue StandardError => e
			# ...
			raise
		rescue SystemExit, Interrupt
			@@logger.error "[#{curConn}] Exiting..."
			raise
		rescue Exception => e
			#...
			raise
		end # begin, rescur
# debug("WebSocket Thread - Finished")
# debug("after ws.start")
	end # def passthrough





	def writeCmd(action, port, queries = nil)
		oq = {}
		oq["action"] =  action
		oq["port"] =  port
		oq["host"] =  @@host
		if !queries.nil?
			oq["queries"] =  queries
		end
		
		debug ("File write [#{oq.to_json}]")
		File.open(@@instructionFile, 'a') { |f| f.puts(oq.to_json) }
	end
	
	def debug(msg)
#		@@logger.debug "#{Thread.current['threadName']} - #{msg}" 	
			puts "#{Thread.current.object_id} #{Thread.current['threadName']} - #{msg}" 		
	end


	private
	
	def Message(status, field, msg) 
		oResp = {}
		oResp["status"] = status
		oResp[field]  = msg
		return oResp
	end # def

	
end # class TcpServer

@@logger = Logger.new STDOUT
# Logger.new('/dev/null')
# 
# @@logger = Logger.new File.new("/var/log/middle.log", 'a')
# @@logger = Logger.new LOGFILE
@@logger.progname = "middle.rb"
#@@logger.debug "Test Log Writing"

# puts "This is Ruby from DNS!"
# STDERR.puts "This is Ruby in STDERR!"
# @@logger.debug "Starting Middle Passthrough Server"
# STDOUT.
puts "Starting Middle Passthrough Server"
s = PassthroughTcpServer.new(searchPort, corePort)
s.waitForConnectionToServer(searchPort)

