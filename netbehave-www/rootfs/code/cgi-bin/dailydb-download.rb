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
require 'cgi'
#require "sqlite3"
#require "json/pure"

folderPath = "/opt/netbehave/core/dailydb/"
cgi = CGI.new
filename = cgi['filename']


cgi.header('Content-Disposition' => 'attachment;filename=#{filename}')
cgi.out 'application/octet-stream' do
    File.open("#{folderPath}#{filename}", 'rb'){|f| f.read}
end
