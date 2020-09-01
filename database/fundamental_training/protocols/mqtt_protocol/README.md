

# MQTT Protocol

* _Classification:_ `Fundamental Training > Protocols`
* _Nodes:_ A8-M3 x 3
* _Difficulty:_ High


## Overview

MQTT (MQ Telemetry Transport) is a machine-to-machine (M2M) IoT
connectivity protocol that was designed as an extremely lightweight
publish/subscribe protocol to transport messages between devices.

In this exercise you will learn about the MQTT protocol and its
constrained variant, called MQTT-SN, using RIOT OS on three A8-M3
nodes in FIT/IoT-LAB. MQTT messages published to the `test/riot` topic
from the Saclay SSH frontend host will be displayed by the MQTT-SN
client running on a RIOT OS node. The experiment nodes will have the
following functions:
* The first node will be used as a border router for propagating an
  IPv6 prefix through its wireless interface.
* The second node will be used as an MQTT broker using the
  [mosquitto.rsmb](https://github.com/eclipse/mosquitto.rsmb)
  application.
* The third node will run an MQTT-SN client to connect with the
  broker.


## Tutorial

1. Connect to the SSH frontend of the Saclay site of FIT/IoT-LAB by
using the `username` you created when you registered with the testbed:
	```
	your_computer:~$ ssh <username>@saclay.iot-lab.info
	```

2. Authenticate with the testbed and submit a 60 minute experiment
using three A8-M3 type nodes (node firmware will be uploaded later),
then wait for the experiment to start:
	```
	username@saclay:~$ iotlab-auth -u <username>
	username@saclay:~$ iotlab-experiment submit -n riot_mqtt -d 60 -l 3,archi=a8:at86rf231+site=saclay
	username@saclay:~$ iotlab-experiment wait
	```

	Make a note of the displayed experiment ID, then get the
	allocated node IDs once the experiment is running by using the
	commands below to retrieve additional information about the
	experiment:
	```
	username@saclay:~$ iotlab-experiment get -i <experiment_ID> -s
	username@saclay:~$ iotlab-experiment get -i <experiment_ID> -r
	```

3. The first node (`a8-1` in our example) will act as a border router
using the `gnrc_border_router` code. To set up its firmware, follow
the instructions below:

	- Clone the RIOT OS repository from GitHub:
		```
		username@saclay:~$ git clone https://github.com/RIOT-OS/RIOT.git
		```

	- Build the `gnrc_border_router` firmware with the appropriate
	baud rate for A8-M3 nodes, which is 500,000:
		```
		username@saclay:~$ source /opt/riot.source
		username@saclay:~$ cd RIOT
		username@saclay:~/RIOT/$ make ETHOS_BAUDRATE=500000 BOARD=iotlab-a8-m3 clean all -C examples/gnrc_border_router
		```

	- Copy and flash the compiled firmware to the first experiment
	node by running the following commands:
		```
		username@saclay:~/RIOT/$ scp examples/gnrc_border_router/bin/iotlab-a8-m3/gnrc_border_router.elf root@node-a8-1:
		username@saclay:~/RIOT/$ ssh root@node-a8-1
		root@node-a8-1:~# flash_a8_m3 gnrc_border_router.elf
		```

4. Configure the network settings of the border router, as follows:

	- Use the first node to compile the tool named `uhcpd` (Micro
	Host Configuration Protocol):
		```
		root@node-a8-1:~# cd ~/A8/riot/RIOT/dist/tools/uhcpd
		root@node-a8-1:~/A8/riot/RIOT/dist/tools/uhcpd# make clean all
		```

	- Also compile the tool named `ethos` (Ethernet Over Serial)
	and configure the public IPv6 network of the node:
		```
		root@node-a8-1:~/A8/riot/RIOT/dist/tools/uhcpd# cd ../ethos
		root@node-a8-1:~/A8/riot/RIOT/dist/tools/ethos# make clean all
		root@node-a8-1:~/A8/riot/RIOT/dist/tools/ethos# ./start_network.sh /dev/ttyA8_M3 tap0 2001:660:3207:401::/64 500000
		```

		Output similar to that shown below will be displayed.
		```
		net.ipv6.conf.tap0.forwarding = 1
		net.ipv6.conf.tap0.accept_ra = 0
		----> ethos: sending hello.
		----> ethos: activating serial pass through.
		----> ethos: hello reply received
		```

5. In another terminal, connect to the second node (`a8-2` in our
example) to configure and start the MQTT broker:

	- Connect to the Saclay SSH frontend, then to second node:
		```
		your_computer:~$ ssh <username>@saclay.iot-lab.info
		username@saclay:~$ ssh root@node-a8-2
		```

	- Edit the configuration file `config.conf` (e.g., by using
	the `vim ` editor) to add the following content:
		```
		# Enable debugging output
		trace_output protocol

		# Listen for MQTT-SN traffic on UDP port 1885
		listener 1885 INADDR_ANY mqtts
		ipv6 true

		# Listen to MQTT connections on TCP port 1886
		listener 1886 INADDR_ANY
		ipv6 true
		```

		This configuration will make the MQTT broker reachable
		from any node behind the border router using MQTT-SN
		on port 1885, and from the SSH frontend using MQTT on
		port 1886.

	- Get the _global_ IPv6 address of this node, as it will be
	needed later to connect to it at step 6:
		```
		root@node-a8-2:~# ip -6 -o addr show eth0
		2: eth0    inet6 2001:660:3207:400::66/64 scope global        valid_lft forever preferred_lft forever
		2: eth0    inet6 fe80::fadc:7aff:fe01:98fc/64 scope link      valid_lft forever preferred_lft forever
		```

	- Start the MQTT broker on the second node:
		```
		root@node-a8-2:~# broker_mqtts config.conf
		```

		The output will be similar to that shown below.
		```
		20170715 001526.077 CWNAN9999I Really Small Message Broker
		20170715 001526.084 CWNAN9998I Part of Project Mosquitto in Eclipse
		(http://projects.eclipse.org/projects/technology.mosquitto)
		20170715 001526.088 CWNAN0049I Configuration file name is config.conf
		20170715 001526.099 CWNAN0053I Version 1.3.0.2, Jul 11 2017 14:55:20
		20170715 001526.102 CWNAN0054I Features included: bridge MQTTS
		20170715 001526.104 CWNAN9993I Authors: Ian Craggs (icraggs@uk.ibm.com), Nicholas O'Leary
		20170715 001526.111 CWNAN0300I MQTT-S protocol starting, listening on port 1885
		20170715 001526.115 CWNAN0014I MQTT protocol starting, listening on port 1886
		```

6. Open a third terminal to prepare the third node (`a8-3` in our
example) as an MQTT-SN client:

	- Log in to the Saclay SSH frontend, build and flash the RIOT
	MQTT-SN firmware:
		```
		your_computer$ ssh <username>@saclay.iot-lab.info
		username@saclay:~$ source /opt/riot.source
		username@saclay:~$ cd RIOT
		username@saclay:~/RIOT$ make BOARD=iotlab-a8-m3 -C examples/emcute_mqttsn
		username@saclay:~/RIOT/$ scp examples/emcute_mqttsn/bin/iotlab-a8-m3/emcute_mqttsn.elf root@node-a8-3:
		username@saclay:~/RIOT/$ ssh root@node-a8-3
		root@node-a8-3:~# flash_a8_m3 emcute_mqttsn.elf
		```

	- Use the command `miniterm.py` to access the shell interface
	of the third node:
		```
		root@node-a8-3:~# miniterm.py /dev/ttyA8_M3 500000 -e
		> help
		```

		The following command menu will be displayed:
		```
		Description
		---------------------------------------
		con                  connect to MQTT broker
		discon               disconnect from the current broker
		pub                  publish something
		sub                  subscribe topic
		unsub                unsubscribe from topic
		will                 register a last will
		reboot               Reboot the node
		ps                   Prints information about running threads
		ping6                Ping via ICMPv6
		random_init          initializes the PRNG
		random_get           returns 32 bit of pseudo randomness
		ifconfig             Configure network interfaces
		ncache               manage neighbor cache by hand
		routers              IPv6 default router list
		```

	- Use the `con` command to connect to the MQTT broker by
	specifying its global IPv6 address retrieved at step 5, then
	subscribe to the `test/riot` topic using the command `sub`:
		```
		> con 2001:660:3207:400::66 1885
		> sub test/riot
		```

7. Use a fourth terminal to test the publish/subscribe mechanism
between the MQTT broker and client nodes:

	- Connect to the Saclay SSH frontend and use the preinstalled
	`mosquitto_pub` command to publish the message "iotrain-lab"
	to the MQTT broker by using its global IPv6 address determined
	at step 5 and the topic name `test/riot`:
		```
		your_computer$ ssh <username>@saclay.iot-lab.info
		username@saclay:~$ mosquitto_pub -h 2001:660:3207:400::66 -p 1886 -t test/riot -m iotrain-lab
		```

	- In the third terminal (used at step 6), the MQTT-SN client
	that already subscribed to the topic `test/riot` should
	produce the following output:
		```
		### got publication for topic 'test/riot' [1] ###
		iotrain-lab
		```

	- Next you can try using the `mosquitto_sub` command on the
	SSH frontend (fourth terminal) to subscribe, and the `pub`
	command on the MQTT-SN client (third terminal) to exchange
	messages in the opposite direction.
