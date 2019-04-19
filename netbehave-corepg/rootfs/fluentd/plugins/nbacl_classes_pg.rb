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
require 'pg'      # Sockets are in standard library

require_relative 'nbacl_classes' # .rb
require_relative 'pg_classes' # .rb

class PG_ACL
    	include PgClasses # mixin used since multiple inheritance is not possible in Ruby

	def initialize(p_host, p_db, p_user, p_pass)
		@rules = []
		@nbRules = 0
		@m_dbname = p_db
		@m_dbuser = p_user 
		@m_dbpass = p_pass
		@m_dbhost =  p_host
		
		dbLoad
	end # def initialize
	
	def dbLoad
		if @nbRules == 0
			if dbOpen(@m_dbname, @m_dbuser, @m_dbpass, @m_dbhost)
				create_lookup_table_from_db()
				dbClose
			end
		end
	end
	
	# overwrite
	def sqlCREATE
		# nothing to do
	end

		
	def create_lookup_table_from_db()
		rs = @db.exec("SELECT rulename, rulecsv FROM acl")
		rs.each do |row|
      		parse_row_db(row)
		end
		$log.info "PG_ACL:create_lookup_table_from_db::Loaded #{@nbRules} rules"
	end

		
	def addOtherACL(other)
		@rules = @rules + other.rules
	end
	
	def rules
		return @rules
	end
		
	def match(flow)
		dbLoad
		@rules.each { | rule |
			if MatchRule(rule, flow)
				return rule["name"]
			end
		}
		return nil
	end
	
	private
	
	def MatchRule(rule, flow)
		bResult = true
		rule["fields"].each { | field |
			if !field.match(flow)
				bResult = false
			end
		}
		return bResult	
	end 
	
#	INSERT INTO acl (rulename, rulecsv) 
		
	def parse_row_db(row)
		aclName = row['rulename']
		rowcsv = row['rulecsv'].split(',')
		fields = []
		(0..rowcsv.length-1).each do |col|
			fields[col] = AclField.new(rowcsv[col])
		end
		@rules[@nbRules]  = {}
		@rules[@nbRules]["name"] = aclName
		@rules[@nbRules]["fields"] = fields
		
		@nbRules = @nbRules + 1
	end
	
end #class CSV_ACL