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
# echo server=`getent hosts dnsunbound | cut -d" " -f 1`#8053 >> /etc/dnsmasq.d/forward.conf
TLSserver=`getent hosts dnsfwd | cut -d" " -f 1`
if [ "$TLSserver" == "" ]; then
	echo "ERROR: Secure local forward server not found, defaulting to non-secure"
	echo server=8.8.8.8 > /etc/dnsmasq.d/forward.conf
else
	echo server=$TLSserver#8053 > /etc/dnsmasq.d/forward.conf
fi

dnsmasq -d

# echo "After"