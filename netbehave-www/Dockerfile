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

EXPOSE 5000-5009
EXPOSE 6000-6009

RUN apk add busybox-extras ruby ruby-rdoc nano \
 && apk add sqlite sqlite-dev gcc ruby-dev libc-dev build-base \
 && gem install json_pure sqlite3 websocket-eventmachine-server \
 && rm -rf /var/cache/apk/* \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

RUN addgroup -g 99 log && \
	adduser -G log -D middle && \
	addgroup nobody log && \
	addgroup root log 

COPY rootfs /

RUN  chmod +x /code/cgi-bin/*
RUN  chmod +x /code/*
RUN wget https://raw.githubusercontent.com/phstc/jquery-dateFormat/master/dist/dateFormat.min.js -O /code/js/dateFormat.min.js

# Command line description for independent image dev/testing
