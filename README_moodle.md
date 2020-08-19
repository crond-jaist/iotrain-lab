
# Moodle Container

This file provides details about the procedure needed to set up a
Moodle container that provides Learning Management System (LMS)
features for IoTrain-Lab.

* To set up the container manually, run the following commands from
  the top IoTrain-Lab directory:
	```
	$ git clone https://github.com/jobcespedes/docker-compose-moodle.git && cd docker-compose-moodle
	$ git clone --branch MOODLE_35_STABLE --depth 1 https://github.com/moodle/moodle html
	$ sudo docker-compose up -d
	```

* For security reasons, you should change the username and password
  for the PostgreSQL database used by Moodle by editing the file
  `.env` located in the newly created `docker-compose-moodle`
  directory, then rebuilding the container.

* For more details about this container, check the following page:
  https://github.com/jobcespedes/docker-compose-moodle.
