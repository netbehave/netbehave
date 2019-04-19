FROM netbehave-docker-base

EXPOSE 5000-5009
EXPOSE 6000-6009

RUN apk add busybox-extras ruby ruby-rdoc nano \
 && apk add sqlite sqlite-dev gcc ruby-dev libc-dev build-base \
 && apk add postgresql-dev ruby-bigdecimal ruby ruby-dev ruby-rdoc make gcc libc-dev \
 && gem install json_pure pg websocket-eventmachine-server bigdecimal \
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

