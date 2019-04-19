#!/bin/sh
ipam=`getent hosts netbehave-ipam | cut -d" " -f 1`
if [ "$ipam" == "" ]; then
   ipam="127.0.0.1"
fi

echo "$ipam netbehave-ipam" >> /etc/hosts
cat /etc/hosts
# touch /var/log/middlelog
# chmod 777 /var/log/middle.log
# echo `date +"%Y%m%d-%H%M%S"` >> /var/log/middle.log
# /usr/bin/ruby /websockets/middle.rb &
# 2>&1 /var/log/middle &
#  

/usr/sbin/httpd -f -v -p 80 -h /code