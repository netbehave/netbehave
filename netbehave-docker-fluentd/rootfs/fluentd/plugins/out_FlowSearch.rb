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

require "fluent/plugin/output"
require "socket"
require_relative 'nbacl_classes' # .rb

# TODO: cache ttl
# TODO: storage

module Fluent
  module Plugin
    class FlowSearchOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("FlowSearch", self)


    			config_param :instructionFile, :string, default: nil
    			config_param :host, :string,  default: '127.0.0.1'

			    # 1. load event_loop_helper
			    helpers :event_loop
    
                def configure(conf)
					super
					@searches = []
                end
                def start
                    super
# log.info "FlowSearch::start()"
					@loop = Coolio::Loop.new
					@handler = MyStatWatcher.new(@instructionFile, method(:processCommand))
					
					@loop.attach(@handler)
					@thread = Thread.new(&method(:run))
                end
                def shutdown
# log.info "FlowSearch::shutdown()"
                    super
					@loop.watchers.each { |w| w.detach }
					@loop.stop
#					@handler.close
					@thread.join

                end
                
# INTERVAL = 0.010          
class MyStatWatcher < Cool.io::StatWatcher
  attr_accessor :accessed, :previous, :current

  def initialize(path, callback)
    super path, 0.010
	@fpath = path
	@callback = callback
  end

  def on_change(previous, current)
# @log.info "MyStatWatcher::on_change()"
	if previous.size == current.size
		return
	end
    line = readline(previous.size, current.size)
# puts "MyStatWatcher::on_change(#{previous.size}, #{current.size}) = [#{line}]"
    self.accessed = true
    self.previous = previous
    self.current  = current
    if !line.nil?
	    @callback.call(line)
    end
  end
  
  def readline(lastPos, endPos)
  	f = File.new(@fpath)
  	f.pos = lastPos # seek
  	line = f.gets
  	f.close
  	if line.nil? 
	  	return line
  	end
  	return line.strip
  end 
end # class

			def run
# log.info "FlowSearch::run()"
				@loop.run
				rescue => e
					log.error "unexpected error", error_class: e.class, error: e.message
					log.error_backtrace
			end # def run
			
			def processCommand(line)
# log.info "FlowSearch::processCommand(#{line})"
				begin
					cmd = JSON.parse(line)
					action = cmd["action"]
					if action == "open"
						host = cmd["host"]
						port = cmd["port"]
#						queries = cmd["queries"]
						q = FlowSearch.new(host, port) # , queries
#						log.info q.inspect
						@searches << q
					elsif action == "stop"
						host = cmd["host"]
						port = cmd["port"]
						nb = 0
						isFound = false
						@searches.each do | search |
							if !search.nil?
								if search.isHostPort(host, port)
									isFound = true
									search.stop
#									@searches[nb] = nil
								end
							end
							nb = nb + 1
						end
						if !isFound
							log.warn "FlowSearch::processCommand(#{action}) connection not found [#{host}:#{port}]"
						end
					elsif action == "disconnect"
						host = cmd["host"]
						port = cmd["port"]
						nb = 0
						isFound = false
						@searches.each do | search |
							if !search.nil?
								if search.isHostPort(host, port)
									isFound = true
									search.disconnect
									@searches[nb] = nil
								end
							end
							nb = nb + 1
						end
						if !isFound
							log.warn "FlowSearch::processCommand(#{action}) connection not found [#{host}:#{port}]"
						end					elsif action == "addQueries"
						queries = cmd["queries"]
						host = cmd["host"]
						port = cmd["port"]
						nb = 0
						isFound = false
						@searches.each do | search |
							if !search.nil?
								if search.isHostPort(host, port)
									isFound = true
									search.addOtherACL(queries)
								end
							end
							nb = nb + 1
						end
						if !isFound
							log.warn "FlowSearch::processCommand(#{action}) connection not found [#{host}:#{port}]"
						end
					elsif action == "replaceQueries"
						queries = cmd["queries"]
						host = cmd["host"]
						port = cmd["port"]
						nb = 0
						isFound = false
						@searches.each do | search |
							if !search.nil?
								if search.isHostPort(host, port)
									isFound = true
									search.replaceACL(queries)
#									@searches[nb] = FlowSearch.new(host, port, queries)
								end
							end
							nb = nb + 1
						end
						if !isFound
							log.warn "FlowSearch::processCommand(#{action}) connection not found [#{host}:#{port}]"
						end
					end
					
				rescue JSON::ParserError
					log.error "FlowSearch::processCommand() JSON error parsing [#{line.chomp}]"
					#"ERR|JSON error #{line.chomp}"			
				end

			end 
			


                
			def listen(callback)
#				INTERVAL = 0.010
#log.info "FlowSearch::listen()"
				return watcher
			end # def listen
                

				def emit(tag, es, chain)
#		$log.debug "FlowassetOutput.emit "
					es.each do |time, record|
						handle_record(tag, time, record)
					end
					chain.next
				end # def emit

				def process(tag, es)
#		$log.debug "FlowassetOutput.process "
					es.each do |time, record|
						handle_record(tag, time, record)
					end
				end # def process

			private

				def handle_record(tag, time, record)
#					label = Engine.root_agent.find_label(@destLabel)
#					router = label.event_router

					if !record["flow"].nil?
						flow = record["flow"]
						@searches.each do | search |
							if !search.nil?
# log.info "FlowSearch:search? [#{search.inspect}]"
# log.info "FlowSearch:match? [#{flow.inspect}]"
								if search.match(flow)
# log.info "FlowSearch:matched! [#{flow.inspect}]"
									search.send(flow)
								end
							end
						end # do
					end

	

				end # def handle_record


class FlowSearch
	def initialize(host, port, queries = nil)
		@sock = nil
		@host = host
		@port = port
		if queries.nil? || queries == ""
#			@queries = []
			@rules = nil
		else
#			@queries = queries
			@rules = CSV_ACL.new(queries, 'array')
		end
	end
	
	def stop
			@rules = nil
	end
	
	def addOtherACL(queries = nil)
		if queries.nil? || queries == ""
			# Nothing
		else
			if @rules.nil?
				@rules = CSV_ACL.new(queries, 'array')
			else
				@rules.addOtherACL( CSV_ACL.new(queries, 'array') )
			end
		end

	end
	
	def replaceACL(queries = nil)
		if queries.nil? || queries == ""
			# Nothing
		else
			@rules = CSV_ACL.new(queries, 'array')
		end

	end

	
	def isHostPort(host, port)
		return @host == host && @port == port
	end
		
	def match(flow)
		if @rules.nil? 
			ruleName = nil
		else
			ruleName = @rules.match(flow)
		end
# $log.warn("FlowSearch.match() matched rule #{ruleName}")

		if !ruleName.nil?
			return true
		end
		return false
	end
	
	def send(flow)
		toSocket(flow)
	end
	
	def disconnect
		@sock.close rescue nil
		@sock = nil
	end
	
	private
	
	def toSocket(frecord)
		tries = 0    				
		begin
			connect
			tries ||= 3
			@sock.puts frecord.to_json
#		$log.info("Put to socket: #{frecord.to_json}")
#					chunk.write_to(@sock)
		rescue => e
		  if (tries -= 1) > 0
				disconnect #reconnect
				retry
		  else
				$log.warn("Failed writing data to socket on #{@host}:#{@port}: #{e}")
				disconnect
		  end
		end
	end #toSocket

	def connect
	#   TCPSocket.open(hostname, port)
		$log.info("Connecting to socket: #{@host}:#{@port}")
		@sock ||= TCPSocket.new(@host, @port)
	end


	def reconnect
		disconnect
		connect
	end

end # class


    end
  end
end