#!/bin/sh
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
echo "nameserver 127.0.0.1" > /etc/resolv.conf && \
           echo "options ndots:0" >> /etc/resolv.conf && \
           echo `getent hosts netbehave-dnsserver-tls | cut -d" " -f 1` && \
           exec s6-setuidgid unbound    unbound -d -v
