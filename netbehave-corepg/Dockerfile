FROM netbehave-docker-fluentd

# RUN gem install pg
# RUN fluent-gem install pg

RUN apk --no-cache add postgresql-dev ruby-bigdecimal  \
  && apk add ruby-dev ruby-rdoc make gcc libc-dev \
  && gem install pg \ 
  && gem install bigdecimal \ 
 && rm -rf /var/cache/apk/* \
  && rm -rf /tmp/* /var/tmp/*

EXPOSE 24224
COPY rootfs /

# Command line description for independent image dev/testing
# docker build -t netbehave-core .
# docker run     -v nflogs:/opt/netbehave/logs -v data:/opt/netbehave -it netbehave-core 
# docker run -p 24224:24224/tcp -v netbehave_logs:/var/log -v netbehave_data:/opt/netbehave  -it netbehave-core /bin/sh
