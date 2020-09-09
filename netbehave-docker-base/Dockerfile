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
# Image: netbehave-docker-base : Base Docker Image for NetBehave.org project
# An Alpine image with S6 overlay added
# Adapted from: https://hub.docker.com/r/project42/s6-alpine/, https://github.com/p42/s6-alpine-docker
# Last update date: 

FROM alpine:3.8
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

ENV TZ=America/New_York

RUN apk add --no-cache wget ca-certificates && \
	apk --no-cache --update upgrade && \
	apk add -U tzdata && \
	apk add bind-tools && \
	cd /tmp && \
	wget https://github.com/just-containers/s6-overlay/releases/download/v$S6_OVERLAY_VERSION/s6-overlay-$ARCH.tar.gz && \
	echo "$S6_OVERLAY_MD5HASH *s6-overlay-$ARCH.tar.gz" | md5sum -c - &&  \
	tar xzf s6-overlay-$ARCH.tar.gz -C / && \
	rm s6-overlay-$ARCH.tar.gz

ENTRYPOINT ["/init"]

# Command line description for independent image dev/testing
# docker build -t netbehave-docker-base .
# docker run -v netbehave_logs:/var/log -it netbehave-docker-base 
# docker run -v netbehave_logs:/var/log -v netbehave_data:/opt/netbehave  -it netbehave-docker-base /bin/sh