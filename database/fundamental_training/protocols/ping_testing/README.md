

# Ping Testing

* _Classification:_ `Fundamental Training > Protocols`
* _Nodes:_ M3 x 2
* _Difficulty:_ Easy


## Overview

Ping is a standard request/reply protocol that is often used to test
whether two nodes can communicate with each other. The protocol also
makes possible to estimate the packet loss rate and the round-trip
delay between nodes.

This exercise illustrates the use of ping to do echo request and reply
exchanges between two M3 nodes by leveraging the `gnrc_networking`
example provided in the RIOT repository of FIT/IoT-LAB.


## Tutorial

1. Connect to the SSH frontend of the Saclay site of FIT/IoT-LAB by
using the `username` you created when you registered with the testbed:
	```
	your_computer:~$ ssh <username>@saclay.iot-lab.info
	```

2. Set up the development environment for the RIOT operating system
(we assume the generic environment for FIT/IoT-LAB was already
prepared according to step 2 of the `Node Control` exercise):
	```
	username@saclay~$ cd iot-lab
	username@saclay:~/iot-lab$ make setup-riot
	```

3. Compile the RIOT firmware for M3 type nodes:
	```
	username@saclay:~/iot-lab$ source /opt/riot.source
	username@saclay:~/iot-lab$ cd parts/RIOT/examples/gnrc_networking/
	username@saclay:~/iot-lab/parts/RIOT/examples/gnrc_networking$ BOARD=iotlab-m3 make all
	```

4. Run the experiment via command line on two designated nodes, such
as `m3-9` and `m3-10`:
	```
	username@saclay:~$ cd bin/iotlab-m3/
	username@saclay:~/iot-lab/parts/RIOT/examples/gnrc_networking/bin/iotlab-m3$ iotlab-experiment submit -n Ping_Testing -d 10 -l saclay,m3,9-10,gnrc_networking.elf
	```

5. Connect to one of the experiment nodes, for example `m3-9`:
	```
	username@saclay:~$ nc m3-9 20000
	```

6. Type `help` on the experiment node to see all the available
commands:
	```
	Command              Description
	---------------------------------------
	udp                  send data over UDP and listen on UDP ports
	reboot               Reboot the node
	ps                   Prints information about running threads.
	ping6                Ping via ICMPv6
	random_init          initializes the PRNG
	random_get           returns 32 bit of pseudo randomness
	ifconfig             Configure network interfaces
	txtsnd               send raw data
	fibroute             Manipulate the FIB (info: 'fibroute [add|del]')
	ncache               manage neighbor cache by hand
	routers              IPv6 default router list
	rpl                  rpl configuration tool [help|init|rm|root|show]
	```

7. Check the network parameters of the node by running the command
`ifconfig`:
	```
	Iface  7   HWaddr: 1d:12  Channel: 26  NID: 0x23  TX-Power: 0dBm  State: IDLE CSMA Retries: 4
	Long HWaddr: 36:32:48:33:46:d5:9d:12
	AUTOACK  CSMA  MTU:1280  HL:64  6LO  RTR  IPHC
	Source address length: 8
	Link type: wireless
	inet6 addr: ff02::1/128  scope: local [multicast]
	inet6 addr: fe80::3432:4833:46d5:9d12/64  scope: local
	inet6 addr: ff02::1:ffd5:9d12/128  scope: local [multicast]
	```

	The output above shows that node `m3-9` has the IPv6 address
	`fe80::3432:4833:46d5:9d12`. We also used another terminal to
	connect to node `m3-10` and get its IPv6 address, which is
	`fe80::3432:4833:46d9:962a`.

8. Use the terminal in which you are connected to `m3-9` to send IPv6
ping requests to node `m3-10` via the command `ping6`:
	```
	> ping6 fe80::3432:4833:46d9:962a
	12 bytes from fe80::3432:4833:46d9:962a: id=84 seq=1 hop limit=64 time = 7.109 ms
	12 bytes from fe80::3432:4833:46d9:962a: id=84 seq=2 hop limit=64 time = 4.595 ms
	12 bytes from fe80::3432:4833:46d9:962a: id=84 seq=3 hop limit=64 time = 5.215 ms
	--- fe80::3432:4833:46d9:962a ping statistics ---
	3 packets transmitted, 3 received, 0% packet loss, time 2.0622373 s
	rtt min/avg/max = 4.595/5.639/7.109 ms
	```

	The output shows that there is no packet loss between the two
	nodes, and the average round-trip time is 5.639 ms.
