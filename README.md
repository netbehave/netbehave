# netbehave
# 
NetBehave was first released following its presentation at BSides Ottawa on November 8, 2018.

More information is posted on netbehave.org.
#
# Getting started - the SQLite version
Steps
1. Get a copy of the code (download zip/unzip or git clone)
2. Edit docker-compose.yml file to edit the ENV variable values for netbehave-alerting and netbehave-core
3. Go to the folder and run: docker-compose build [sudo may be required]
4. Go to the folder and run: docker-compose up -d [sudo may be required]
# 
# www
The www server runs at port 8080 by default.
It currently uses basic authentication with user 'nbadmin' and password 'netbehave-www'
#
# Potential issues
# 
Some linux systems may already have a DNS application running which should be disabled (or ports changed).
Please report other issues to the Issues portion of the repository
#
# Getting started - the Postgres Version version (2019-03-26)
Steps
1. Get a copy of the code (download zip/unzip or git clone)
2. Go to the app-pg folder (cd app-pg)
3. Edit docker-compose.yml file to edit the ENV variable values for netbehave-alerting and netbehave-corepg
4. Go to the folder and run: docker-compose build [sudo may be required]
5. Go to the folder and run: docker-compose up -d [sudo may be required]
#
Same www settings for the PG version
#
# PG is listening on its regular 5432/tcp port.
# See this post for more info: 