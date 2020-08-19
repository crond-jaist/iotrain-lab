
# CentOS Container (Xfce4 & VNC)

This directory contains the files needed to set up a CentOS container
with the Xfce4 desktop environment that runs a "headless" VNC session.

* To set up the container manually, run the following command:
	```
	$ sudo docker-compose up -d
	```

* To check whether the container is running, run the following
  command:
	```
	$ sudo docker ps -a
	```

	The output should be similar to that shown below.
	```
	CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS                NAMES
	07c9b173f807        dockercentosxfcevnc_container1   "/dockerstartup/vnc_…"   27 seconds ago      Up 23 seconds       5901/tcp, 6901/tcp   dockercentosxfcevnc_container1_1
	```

* For more details about this container, check the following page:
  https://hub.docker.com/r/consol/centos-xfce-vnc/.
