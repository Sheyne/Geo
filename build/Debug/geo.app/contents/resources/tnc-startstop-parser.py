#! /usr/bin/python
import serial
import optparse
import os
import time
import datetime
try:
	parse=optparse.OptionParser(description='Reads xastir type tnc start and stop files.',
							  prog='tnc-startstop-parser.py',
	      						  version='%prog 0.1',
	      						  usage='%prog -p SERIAL_PORT -f tnc-start/stopfile')
	parse.add_option('--port','-p', default="/dev/tty.PL2303-000013FD")
	parse.add_option('--file','-f', default="/Users/sheyne/.xastir/config/tnc-startup.d700")
	options, arguments = parse.parse_args()
	ser=False
	while not ser:
		try:
			ser=serial.Serial(options.port)
		except serial.SerialException as err:
			options.port=raw_input(str(err)+" Invalid Serial Port, New Port: ").strip()
	fi=False
	while not fi:
		try:
			fi=open(os.path.expanduser(options.file),"r")
		except IOError as err:
			options.file=raw_input(str(err)+", File: ").strip()
	sendCtrlC="\x03"
	for line in fi:
		if line[0]=="#":
			if line[1:7]=="#META ":
				line=line[7:-1]
				if line=="<delay>":
					print "Sleeping for .5 seconds."
					time.sleep(.5)
				if line=="<no-ctrl-c>":
					print "no ctrl c"
					sendCtrlC=""
		else:
			ser.write(sendCtrlC)
			ser.write(line.strip()+"\r\n")
			print "sent:",line.strip()
			sendCtrlC="\x03"
except KeyboardInterrupt:
	ser.close()
	fi.close()