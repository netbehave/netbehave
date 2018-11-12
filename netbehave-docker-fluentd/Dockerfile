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
FROM alpine:3.7

# FROM alpine:3.8
ARG ARCH=amd64
# ARG ARCH=armhf

# Previous version for x86
# ENV S6_OVERLAY_VERSION 1.21.4.0
# ENV S6_OVERLAY_MD5HASH 3eb36dc6524522d8c637106ce74ded18

# Current version
ARG S6_OVERLAY_VERSION=1.21.7.0
# amd64 (x86_64) variables
ARG S6_OVERLAY_MD5HASH=e034e40f303559e85c01416d1ec42f96
# armhf 
# ENV S6_OVERLAY_MD5HASH 6a1edb63213475963b21890d370da4bd



ENV SU_EXEC_VERSION=0.2

ARG DEBIAN_FRONTEND=noninteractive
# Do not split this into multiple RUN!
# Docker creates a layer for every RUN-Statement
# therefore an 'apk delete' has no effect
RUN apk update \
 && apk upgrade \
 && apk add git openssh ruby-dev build-base gcc sqlite sqlite-dev libc-dev nano \
 && apk add --no-cache \
        ca-certificates \
        ruby ruby-irb \
        su-exec==${SU_EXEC_VERSION}-r0 \
 && apk add --no-cache --virtual .build-deps \
        build-base \
        ruby-dev wget gnupg \
 && update-ca-certificates \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install oj -v 3.3.10 \
 && gem install json -v 2.1.0 \
 && gem install fluentd -v 1.2.5 \
 && gem install bindata sqlite3 fluent-plugin-flowcounter \
 && apk del .build-deps \
 && rm -rf /var/cache/apk/* \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

#        dumb-init==${DUMB_INIT_VERSION}-r0 \ # replaced by s6

# *** S6 portion

ENV S6_OVERLAY_VERSION 1.21.4.0
ENV S6_OVERLAY_MD5HASH 3eb36dc6524522d8c637106ce74ded18

ENV TZ=America/New_York

RUN apk add -U tzdata

RUN apk add --no-cache wget ca-certificates && \
	apk --no-cache --update upgrade && \
	cd /tmp && \
	wget https://github.com/just-containers/s6-overlay/releases/download/v$S6_OVERLAY_VERSION/s6-overlay-amd64.tar.gz && \
	echo "$S6_OVERLAY_MD5HASH *s6-overlay-amd64.tar.gz" | md5sum -c - &&  \
	tar xzf s6-overlay-amd64.tar.gz -C / && \
	rm s6-overlay-amd64.tar.gz

# for log storage (maybe shared with host)
RUN mkdir -p /fluentd/log
# configuration/plugins path (default: copied from .)
RUN mkdir -p /fluentd/etc /fluentd/plugins /fluentd/bin

# -S  -s /bin/false 
RUN addgroup -g 99 log && \
	adduser -G log -D fluent && \
	addgroup nobody log && \
	addgroup root log 

ENV PATH /fluentd/bin:$PATH
COPY rootfs /

ENV FLUENTD_OPT=""
ENV FLUENTD_CONF="fluent.conf"


ENTRYPOINT ["/init"]

# Command line description for independent image dev/testing
# docker build -t netbehave-docker-fluentd .
# docker run -it netbehave-docker-fluentd