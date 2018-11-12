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
# NetBehave.org - Network Behavioral Analysis framework
# Image adapted From: https://hub.docker.com/r/andyshinn/dnsmasq

FROM netbehave-docker-base

# LABEL description="Runs a DNS server " 

RUN apk add dnsmasq

COPY rootfs /
RUN chmod +x /dnsmasq-start.sh

ENTRYPOINT ["/init"]

# Command line description for independent image dev/testing
# docker run -p 53:53/tcp -p 53:53/udp --cap-add=NET_ADMIN --volumes-from dnsmasq_log -e DNSFORWARD=1.1.1.1 -it dnsmasq 
# docker run -p 53:53/tcp -p 53:53/udp --cap-add=NET_ADMIN --volumes-from dnsmasq_log -it pi-dnsmasq 
# docker run -p 2053:2053/tcp -p 2053:2053/udp --cap-add=NET_ADMIN -v netbehave_logs:/var/log -v netbehave_data:/opt/netbehave -it netbehave-dnsserver
# docker build -t pi-dnsmasq .
# dnsmasq -p 2053 -k


# docker run -p 2053:2053/tcp -p 2053:2053/udp --cap-add=NET_ADMIN -v netbehave_logs:/var/log -v netbehave_data:/opt/netbehave -it netbehave-dnsserver