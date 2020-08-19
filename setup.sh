#!/bin/bash

#########################################################################
# Script that sets up IoTrain-Lab prerequisite packages and containers
#########################################################################


#########################################################################
# Install the necessary tools
echo "------------------------------------------------------------------"
echo " PACKAGE INSTALLATION"
echo "------------------------------------------------------------------"

## Install docker
echo "* Install the package docker.io"
sudo apt-get install docker.io
sudo systemctl start docker
sudo systemctl enable docker

## Install docker-commpose
echo
echo "* Install the package docker-compose"
sudo apt-get install docker-compose


#########################################################################
# Set up the containers
echo
echo "------------------------------------------------------------------"
echo " CONTAINER SETUP"
echo "------------------------------------------------------------------"

# Get the directory where the installation script is located
MAIN_DIR=$(cd $(dirname $0) && pwd )

## Set up CentOS
CENTOS_DIR=${MAIN_DIR}"/docker-centos-xfce-vnc"
echo "* Set up the CentOS container"
cd ${CENTOS_DIR}
sudo docker-compose up -d

## Set up Guacamole
GUACAMOLE_DIR=${MAIN_DIR}"/docker-guacamole"
echo
echo "* Set up the Guacamole container'"
cd ${GUACAMOLE_DIR}
sudo docker-compose up init-guacamole-db
sudo docker-compose up -d

## Set up Moodle
MOODLE_DIR=${MAIN_DIR}"/docker-compose-moodle"
echo
echo "* Set up the Moodle container"
cd ${MAIN_DIR}
git clone https://github.com/jobcespedes/docker-compose-moodle.git && cd ${MOODLE_DIR}
git clone --branch MOODLE_35_STABLE --depth 1 https://github.com/moodle/moodle html
sudo docker-compose up -d

echo
echo "* Setup finished"
cd ${MAIN_DIR}


#########################################################################
# Print final notes
echo
echo "------------------------------------------------------------------"
echo " NOTES"
echo "------------------------------------------------------------------"
echo "* You can check docker.io installation as follows:"
echo "  $ docker --version"
echo "  $ sudo docker run hello-world"
echo "* You can check docker-compose installation as follows:"
echo "  $ docker-compose --version"
echo "* You can verify the containers are running as follows:"
echo "  $ sudo docker ps -a"
echo "* If your host is using a proxy to connect to the Internet,"
echo "  setup will fail unless you configure Docker to use the"
echo "  proxy server. See the following links for details:"
echo "  - https://www.thegeekdiary.com/how-to-configure-docker-to-use-proxy/"
echo "  - https://docs.docker.com/network/proxy/"
