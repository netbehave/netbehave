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
require "fluent/plugin/filter"
# require "json"
require 'csv'

module Fluent
  module Plugin
    class FlowServiceFilter < Fluent::Plugin::Filter
      Fluent::Plugin.register_filter("FlowService", self)

# TODO: allow additional csv info
		config_param :strict, :bool, :default => false

	def configure(conf)
                        super
                        table_file = File.expand_path('../services.csv', __FILE__)
                        @lookup_table = create_lookup_table(table_file)
		log.info "FlowServiceFilter:configure #{@lookup_table.size} services loaded"
	end

		def filter(tag, time, record)		
			 if record["flow"]["protocol_name"] == "TCP" || record["flow"]["protocol_name"] == "UDP"
				srckey = "#{record["flow"]["src"]["port"]}/#{record["flow"]["protocol_name"].downcase}"
				dstkey = "#{record["flow"]["dst"]["port"]}/#{record["flow"]["protocol_name"].downcase}"
				if @lookup_table.key?(srckey)
					record["flow"]["serviceName"] = @lookup_table[srckey]["serviceName"]
					record["flow"]["serviceDescription"] = @lookup_table[srckey]["serviceDescription"]
					record["flow"]["serviceDirection"] = "src"

				elsif @lookup_table.key?(dstkey)
					record["flow"]["serviceName"] = @lookup_table[dstkey]["serviceName"]
					record["flow"]["serviceDescription"] = @lookup_table[dstkey]["serviceDescription"]
					record["flow"]["serviceDirection"] = "dst"
				end

			 end
			record
		end # def filter

	private

    
		def create_lookup_table(file)
			begin
				lookup_table = {}
				CSV.foreach(file) do |row|
					handle_row(lookup_table, row)
				end

				if (strict && lookup_table.length == 0)
					raise ConfigError, "Lookup file is empty"
				end

				return lookup_table
			rescue Errno::ENOENT => e
				handle_file_err(file, e)
			rescue Errno::EACCES => e
				handle_file_err(file, e)
			end # begin
		end # def create_lookup_table(file)

				
				def handle_row(lookup_table, row)
					if (row.length < 3)
						return handle_row_error(row, "Too few columns : #{row.length} instead of 3")
					end

					# If too much columns
					if (strict && row.length > 3)
						return handle_row_error(row, "Too much columns : #{row.length} instead of 3")
					end

					# If duplicates
					if (strict && lookup_table.has_key?(row[0]))
						return handle_row_error(row, "Duplicate entry")
					end

					lookup_table[row[0]] = {} 
					lookup_table[row[0]]["serviceName"] = row[1]
					lookup_table[row[0]]["serviceDescription"] = row[2]
					#$log.warn "csv pair ", row[0], row[1]
				end # def handle_row(lookup_table, row)
				
				def handle_row_error(row, errmsg)
					log.error "FlowNormalizerFilter row error ", row:row, error:errmsg 
				end # def handle_row_error(row, errmsg)
				
				def handle_file_err(file, err)
					log.error "FlowNormalizerFilter file error ", file:file, error:err 
				end # def handle_file_err(file, err)
				
    

    end # class

=begin

=end

  end
end

=begin
=end
