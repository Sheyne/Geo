import serial
import os
import time

startupFile="~/.xastir/config/tnc-startup.d700"
shutdownFile="~/.xastir/config/tnc-stop.d700"
serialPort="/dev/tty.PL2303-000013FD"
logFile="~/Desktop/serial.log"

def parseTNCCommandFile(fi,ser):
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
	fi.close()


startupFile=open(os.path.expanduser(startupFile))
logFile=open(os.path.expanduser(logFile))
ser=serial.Serial(serialPort,baudrate=4800)
try:
	parseTNCCommandFile(startupFile,ser)
	print "started"
	while True:
		print "a"+ser.read(1)+"a"
	#	currentTimestamp="# "+str(int(round(time.time())))+datetime.datetime.now().strftime(" %a %b %d %H:%M:%S %Z %Y")
	#	print currentTimestamp
	#	print line.strip()
	#	logFile.write(currentTimestamp+"\n")
	#	logFile.write(line.strip()+"\n")
	#	logFile.flush()


except KeyboardInterrupt:
	logFile.close()
	shutdownFile=open(os.path.expanduser(shutdownFile))
	parseTNCCommandFile(shutdownFile,ser)
	ser.close()
