#! /usr/bin/python
import serial
import optparse
import os
import time
import datetime
try:
	parse=optparse.OptionParser(description='Logs Serial Packets',
							  prog='seriallogger.py',
	      						  version='seriallogger.py 0.1',
	      						  usage='%prog -p SERIAL_PORT -o OutFile.log')
	parse.add_option('--port','-p', default="/dev/tty.PL2303-000013FD")
	parse.add_option('--out','-o', default=os.path.join("~","Desktop","serial.log"))
	options, arguments = parse.parse_args()
	ser=False
	while not ser:
		try:
			ser=serial.Serial(options.port)
		except serial.SerialException:
			options.port=raw_input("Invalid Serial Port, New Port: ")
	outfile=False
	while not outfile:
		try:
			outfile=open(os.path.expanduser(options.out),"a")
		except IOError as err:
			options.out=raw_input(str(err)+", New Out File: ")
	for line in ser:
		currentTimestamp="# "+str(int(round(time.time())))+datetime.datetime.now().strftime(" %a %b %d %H:%M:%S %Z %Y")
		print currentTimestamp
		print line.strip()
		outfile.write(currentTimestamp+"\n")
		outfile.write(line.strip()+"\n")
		outfile.flush()
except KeyboardInterrupt:
	outfile.close()