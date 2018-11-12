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

FROM netbehave-docker-base

RUN apk --no-cache add ruby ruby-dev ruby-rdoc sqlite sqlite-dev make gcc libc-dev && \
	gem install sqlite3 json && \
	rm -rf /var/cache/apk/* && \
	rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

RUN addgroup -g 99 log && \
	adduser -G log -s /bin/false -S -D dnscache && \
	addgroup nobody log && \
	addgroup root log 

COPY rootfs /

# ENV PATH /code:$PATH

# Command line description for independent image dev/testing
# docker build -t netbehave-dnscache .
# docker run -e S6_LOGGING=0 -p 12001:10001/tcp -p 12002:10002/tcp -p 12003:10003/tcp -it netbehave-dnscache
# docker run -e DNSCACHEDATADIR=/opt/netbehave/dnscache -p 12001:10001/tcp -p 12002:10002/tcp -p 12003:10003/tcp  -v netbehave_logs:/var/log -v netbehave_data:/opt/netbehave  -it netbehave-dnscache /bin/sh