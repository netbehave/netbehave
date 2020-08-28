#
# Copyright 2019: Yves Desharnais
# Part of NetBehave.org system
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require "json"
require 'ipaddr'
require 'net/http'
require 'pg'

module PgClasses
		def dbOpen(p_dbname, p_dbuser,  p_dbpass, p_dbhost)
			if @db.nil?
				begin
#					log.debug "PgClasses:dbOpen(#{p_dbuser}@#{p_dbhost}/#{p_dbname}) attempting to connect to database."
					@db = PG.connect( dbname: p_dbname, user: p_dbuser,  password: p_dbpass, host: p_dbhost)
					sqlCREATE
					return true
				rescue 
					log.error "PgClasses:dbOpen(#{p_dbuser}@#{p_dbhost}/#{p_dbname}) connection could not be opened."
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
		
		def sqlCREATE
			# shoud be overwritten
			log.debug "PgClasses::sqlCREATE not overwritten [#{self.class.name.to_s}]"
		end 
		
		def PG_Error_to_s(err)
			# errstr = ""
			errstr = "PG::Error "
			errstr += [
				err.result.error_field( PG::Result::PG_DIAG_SEVERITY ),
				err.result.error_field( PG::Result::PG_DIAG_SQLSTATE ),
				err.result.error_field( PG::Result::PG_DIAG_MESSAGE_PRIMARY ),
				err.result.error_field( PG::Result::PG_DIAG_MESSAGE_DETAIL ),
				err.result.error_field( PG::Result::PG_DIAG_MESSAGE_HINT ),
				err.result.error_field( PG::Result::PG_DIAG_STATEMENT_POSITION ),
				err.result.error_field( PG::Result::PG_DIAG_INTERNAL_POSITION ),
				err.result.error_field( PG::Result::PG_DIAG_INTERNAL_QUERY ),
				err.result.error_field( PG::Result::PG_DIAG_CONTEXT ),
				err.result.error_field( PG::Result::PG_DIAG_SOURCE_FILE ),
				err.result.error_field( PG::Result::PG_DIAG_SOURCE_LINE ),
				err.result.error_field( PG::Result::PG_DIAG_SOURCE_FUNCTION ),
				].to_s
			return errstr
		end
		
end # module Fluent
 

