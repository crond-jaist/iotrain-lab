

# Node Control

* _Classification:_ `Fundamental Training > Devices`
* _Nodes:_ M3 x 1
* _Difficulty:_ Easy


## Overview

Learning how to interact with an IoT device in order to get sensor
data, such as temperature, luminosity and pressure, is a fundamental
step for anyone studying the field of IoT.

In this exercise you will learn how to retrieve sensor data using an
example demo program for the [M3
nodes](https://www.iot-lab.info/docs/boards/iot-lab-m3/), which are a
basic type of nodes available in FIT/IoT-LAB.


## Tutorial

1. Connect to the SSH frontend of the Saclay site of FIT/IoT-LAB by
using the `username` you created when you registered with the testbed:
	```
	your_computer:~$ ssh <username>@saclay.iot-lab.info
	```

2. Prepare the general development environment for FIT/IoT-LAB:
	```
	username@saclay~$ git clone https://github.com/iot-lab/iot-lab.git
	username@saclay~$ cd iot-lab
	username@saclay:~/iot-lab$ make
	username@saclay:~/iot-lab$ make setup-openlab
	```

3. Set up the development environment for the M3 type nodes used in
this exercise:
	```
	username@saclay:~/iot-lab$ cd parts/openlab
	username@saclay:~/iot-lab/parts/openlab$ mkdir build.m3; cd build.m3/
	username@saclay:~/iot-lab/parts/openlab/build.m3$ cmake .. -DPLATFORM=iotlab-m3
	```

4. Compile the M3 firmware for the example demo tutorial used in this
exercise:
	```
	username@saclay:~/iot-lab/parts/openlab/build.m3$ make tutorial_m3
	```

5. Use the command line to submit an experiment that has a 10 minute
duration and uses one M3 node on the Saclay site loaded with the
firmware compiled above:
	```
	username@saclay:~$ iotlab-experiment submit -n ControlNode -d 10 -l 1,archi=m3:at86rf231+site=saclay,tutorial_m3.elf
	```

6. Make note of the experiment ID printed by the above command, and
once the experiment is running retrieve the ID of the M3 node that was
allocated automatically for this experiment:
	```
	username@saclay:~$ iotlab-experiment get -i <experiment_ID> -ri
	```

7. Connect to the allocated node (in this example we'll assume the
node `m3-2`):
	```
	username@saclay:~$ nc m3-2 20000
	```

8. Interact with the experiment node via the demo program by typing
commands as shown in the help menu:
	```
	IoT-LAB Simple Demo program
	Type command
		h:	print this help
		t:	temperature measure
		l:	luminosity measure
		p:	pressure measure
		u:	print node uid
		d:	read current date using control_node
		s:	send a radio packet
		b:	send a big radio packet
		e:	toggle leds blinking

	Type Enter to stop printing this help

	cmd > t
	Chip temperature measure: 4.7525E1

	cmd > l
	Luminosity measure: 2.4414062E-1 lux

	cmd > p
	Pressure measure: 9.9412036E2 mabar

	cmd > u
	Current node uid: 4061 (m3-2)

	cmd > d
	Control Node time: 1564947067.599536. Date is: UTC 2019-08-04 19:31:07.599536
	```
	In addition to retrieving sensor data and node information,
	the demo program can also be used to send radio packets and to
	turn the LEDs on/off.

### Note

* The [web portal](https://www.iot-lab.info/testbed/dashboard) of
  FIT/IoT-LAB can be used instead of the command-line interface to
  create experiments, reserve nodes, upload their firmware and run the
  defined experiments, as it will be shown in the tutorial
  `Consumption Monitoring`.
