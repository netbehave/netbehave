# netbehave-pg-initdb

FROM alpine:latest

# Version (11.1-r0) in alpine packages
RUN apk --no-cache add bash postgresql-dev ruby-bigdecimal  \
  && apk add ruby ruby-dev ruby-rdoc make gcc libc-dev \
  && gem install pg \ 
  && gem install bigdecimal \ 
 && rm -rf /var/cache/apk/* \
  && rm -rf /tmp/* /var/tmp/*

  
#   /usr/lib/ruby/gems/*/cache/*.gem
#  sqlite sqlite-dev  && \
#json \
# 	adduser -G log -s /bin/false -S -D ipam && \
# -S 
#RUN addgroup -g 99 log && \
#	addgroup nobody log && \
#	addgroup root log 
#	adduser -G log -D postgres && \

COPY rootfs /

CMD ruby /code/initdb.rb




# docker build -t netbehave.ipam .
# docker run  -p 11001:11001/tcp -p 11002:11002/tcp -p 11003:11003/tcp -v ipam_logs:/opt/netbehave/logs/ipam -v ipam_data:/opt/netbehave/ipam  -it netbehave.ipam
# docker run  -p 11001:11001/tcp -p 11002:11002/tcp -p 11003:11003/tcp -v ipam_logs:/opt/netbehave/logs/ipam -v ipam_data:/opt/netbehave/ipam  -it netbehave.ipam
# docker run -v netbehave_logs:/var/log -v netbehave_data:/opt/netbehave -p 11001:11001/tcp -p 11002:11002/tcp -p 11003:11003/tcp -it netbehave-ipam
# docker run -e IPAMDATADIR=/opt/netbehave/ipam -v netbehave_logs:/var/log -v netbehave_data:/opt/netbehave -p 11001:11001/tcp -p 11002:11002/tcp -p 11003:11003/tcp -it netbehave-ipam
