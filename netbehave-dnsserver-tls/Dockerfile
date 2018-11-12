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
# Label reference="adapted from https://github.com/qdm12/cloudflare-dns-server"

FROM netbehave-docker-base

LABEL description="Runs a DNS server connected to the secured Cloudflare DNS server 1.1.1.1" 
EXPOSE 8053/udp

RUN apk add --update --no-cache -q --progress unbound && \
    rm -rf /etc/unbound/unbound.conf /var/cache/apk/*

RUN addgroup -g 99 log && \
	addgroup unbound log && \
	addgroup nobody log && \
	addgroup root log 


COPY rootfs /

RUN chmod +x /unbound-start.sh

ENTRYPOINT ["/init"]

# Command line description for independent image dev/testing
