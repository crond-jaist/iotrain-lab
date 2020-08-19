
# Guacamole Containers

This directory contains the files needed to set up the containers
necessary in order to run the Apache Guacamole client-less remote
desktop gateway.

* Before setting up the containers, for security reasons you should
  edit the file `.env` in this directory to change the username and
  password for the PostgreSQL database.

* To set up the container manually, you should first initialize the
  Guacamole database, then build and start the Guacamole container:
	```
	$ sudo docker-compose up init-guacamole-db
	$ sudo docker-compose up -d
	```

* To check whether the necessary containers are running, run the
  following command:
	```
	$ sudo docker ps -a
	```

	The output should be similar to that shown below.
	```
	CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS                NAMES
	ee0a2bba31c3        guacamole/guacamole:latest       "/opt/guacamole/bin/…"   10 seconds ago      Up 9 seconds                0.0.0.0:8080->8080/tcp   dockerguacamole_guac_1
	cd1b76fab064        postgres:latest                  "docker-entrypoint.s…"   12 seconds ago      Up 10 seconds               5432/tcp                 dockerguacamole_postgres_1
	2ae240847c72        guacamole/guacd:latest           "/bin/sh -c '/usr/lo…"   15 seconds ago      Up 11 seconds               4822/tcp                 dockerguacamole_guacd_1
	```

* Once the three containers mentioned above are all running, you can
  use your browser to access the Guacamole service:
  http://localhost:8080/guacamole/.

* The default username and password for Guacamole are `guacadmin`. For
  security reasons, please change the password immediately after the
  first login.
