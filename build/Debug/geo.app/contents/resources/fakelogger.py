#! /usr/bin/python
import serial
import optparse
import os
import time
import datetime
def raw_i():
	while True:
		yield raw_input()
def old_i():
	count=0
	print "///"
	for line in infile:
		if count%2==1:
			print "Display packet \"",line.strip(),
			if not 'n' in raw_input("\"? (y/n)"):
				yield line
		count+=1
try:
	infile=False
	outfile=False
	inf="~/Desktop/sampletnc.log"
	out="~/Desktop/serial.log"
	while not infile:
		try:
			infile=open(os.path.expanduser(inf),"r")
		except IOError as err:
			inf=raw_input(str(err)+", New In File: ")
	while not outfile:
		try:
			outfile=open(os.path.expanduser(out),"a")
		except IOError as err:
			out=raw_input(str(err)+", New Out File: ")
	for line in old_i():
		current_time=time.time()
		outfile.write("# "+str(int(current_time))+datetime.datetime.fromtimestamp(current_time).strftime(" %a %b %d %H:%M:%S %Z %Y")+"\n")
		outfile.write(line.strip()+"\n")
		outfile.flush()
except KeyboardInterrupt:
	outfile.close()
	infile.close()