

# CoAP Protocol

* _Classification:_ `Fundamental Training > Protocols`
* _Nodes:_ M3 x 2
* _Difficulty:_ High


## Overview

CoAP (Constrained Application Protocol) is a specialized web transfer
protocol used with constrained nodes and networks in the Internet of
Things. The protocol is designed for machine-to-machine (M2M)
applications, such as smart energy and building automation.

In this exercise you will learn about the basics of CoAP using RIOT OS
and leveraging the `gnrc_border_router` and `microcoap_server`
examples provided in the RIOT OS repository on GitHub.


## Tutorial

1. Connect to the SSH frontend of the Grenoble site of FIT/IoT-LAB by
using the `username` you created when you registered with the testbed:
	```
	your_computer:~$ ssh <username>@grenoble.iot-lab.info
	```

2. Authenticate with the testbed and submit a 60 minute experiment
using two M3 type nodes (node firmware will be uploaded later), then
wait for the experiment to start:
	```
	username@grenoble:~$ iotlab-auth -u <username>
	username@grenoble:~$ iotlab-experiment submit -n riot_coap -d 60 -l 2,archi=m3:at86rf231+site=grenoble
	username@grenoble:~$ iotlab-experiment wait
	```

	Make a note of the displayed experiment ID, then get the
	allocated node IDs once the experiment is running by using the
	commands below to retrieve additional information about the
	experiment:
	```
	username@grenoble:~$ iotlab-experiment get -i <experiment_ID> -s
	username@grenoble:~$ iotlab-experiment get -i <experiment_ID> -r
	```

3. The first node (`m3-1` in our example) will act as a border router
using the `gnrc_border_router` code. To set up its firmware, follow
the instructions below:

	- Clone the RIOT OS repository from GitHub:
		```
		username@grenoble:~$ git clone https://github.com/RIOT-OS/RIOT.git
		```

	- Build the `gnrc_border_router` firmware with the appropriate
	baud rate for M3 nodes, which is 500,000; to minimize radio
	interference with other experiments, you can use a different
	802.15.4 channel than the default value 26 by adding the
	`DEFAULT_CHANNEL` option to the `make` command below:
		```
		username@grenoble:~$ source /opt/riot.source
		username@grenoble:~$ cd RIOT
		username@grenoble:~/RIOT/$ make ETHOS_BAUDRATE=500000 DEFAULT_CHANNEL=20 BOARD=iotlab-m3 -C examples/gnrc_border_router clean all
		```

	- Flash the compiled firmware to the first experiment node by
	running the following command:
		```
		username@grenoble:~/RIOT/$ iotlab-node --update examples/gnrc_border_router/bin/iotlab-m3/gnrc_border_router.elf -l grenoble,m3,1
		```

4. Configure the network settings of the border router and propagate
an IPv6 prefix by using the command `ethos_uhcpd.py`:
	```
	username@grenoble:~$ sudo ethos_uhcpd.py m3-1 tap0 2001:660:5307:3100::1/64
	```

	If the command above fails, check whether the `tap0` network
	interface is not already in use, as you may need to choose
	another one. If you see the error "overlaps with routes",
	another experiment is using the same IPv6 prefix (e.g.,
	`2001:660:5307:3100::1/64`), so you need to change it (more
	information about the IPv6 support in FIT/IoT-LAB is available
	[here](https://www.iot-lab.info/docs/getting-started/ipv6/)).
	To view the currently used IPv6 prefixes, run the command `ip
	-6 route` on the SSH frontend; the output will look similar to
	that shown below.
	```
	2001:660:5307:30fff::/64 dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440 hoplimit 4294967295
	2001:660:5307:3100::/64 dev tun0  proto kernel  metric 256  mtu 1500 advmss 1440 hoplimit 4294967295
	fe80::/64 dev eth1  proto kernel  metric 256  mtu 1500 advmss 1440 hoplimit 4294967295
	fe80::/64 dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440 hoplimit 4294967295
	fe80::/64 dev tun0  proto kernel  metric 256  mtu 1500 advmss 1440 hoplimit 4294967295
	default via 2001:660:5307:30ff:ff:: dev eth0  metric 1  mtu 1500 advmss 1440 hoplimit 4294967295
	```

	When the border router network is correctly configured, the
	`ethos_uhcpd.py` command output should be as shown below:
	```
	net.ipv6.conf.tap0.forwarding = 1
	net.ipv6.conf.tap0.accept_ra = 0
	----> ethos: sending hello.
	----> ethos: activating serial pass through.
	----> ethos: hello reply received
	```

5. In another terminal, connect again to the Grenoble SSH frontend and
set up the other experiment node (`m3-2` in our example) using the
RIOT `microcoap_server` code:

	- Compile the firmware (if you changed the default channel,
	make sure to use the same setting for the `make` command
	below):
		```
		your_computer:~$ ssh <username>@grenoble.iot-lab.info
		username@grenoble:~$ source /opt/riot.source
		username@grenoble:~$ cd RIOT
		username@grenoble:~/RIOT/$ make DEFAULT_CHANNEL=<channel> BOARD=iotlab-m3 -C examples/microcoap_server clean all``
		```

	- Flash the compiled firmware to the second experiment node by
	running the following command:
		```
		username@grenoble:~/RIOT/$ iotlab-node --update examples/microcoap_server/bin/iotlab-m3/microcoap_server.elf -l grenoble,m3,2
		```

6. Use the shell interface of the border router to find out the IPv6
address of the node running the CoAP server. For this purpose, type
"Enter" in the terminal of where you ran the `ethos_uhcpd.py` script
to access the RIOT shell, then type the command `nib neigh`:
	```
	> help
	help
	Command              Description
	---------------------------------------
	reboot               Reboot the node
	ps                   Prints information about running threads.
	ping6                Ping via ICMPv6
	random_init          initializes the PRNG
	random_get           returns 32 bit of pseudo randomness
	nib                  Configure neighbor information base
	ifconfig             Configure network interfaces
	fibroute             Manipulate the FIB (info: 'fibroute [add|del]')
	6ctx                 6LoWPAN context configuration tool

	> nib neigh
	nib neigh
	[...]
	2001:660:3207:4c1:1711:6b10:65fd:bd36 dev #6 lladdr 15:11:6b:10:65:fd:bd:36  STALE REGISTERED
	```

7. In a new terminal log in to the Grenoble SSH frontend, and use the
`coap` command to query the CoAP server and confirm that it is
operating correctly. By default, the CoAP server of RIOT exposes only
the board type to a CoAP GET request on `/riot/board`. To get this
information run the following command (make sure to use the CoAP
server address identified at step 6 above):
	```
	username@grenoble:~$ coap get coap://[2001:660:3207:4c1:1711:6b10:65fd:bd36]/riot/board
	(2.05)	iotlab-m3
	```
