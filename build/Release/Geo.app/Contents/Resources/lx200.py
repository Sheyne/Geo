import serial
from time import sleep
from glob import glob

"""
By Sheyne Anderson 10:55 AM May 6 2011

version 1.0
"""

class TelescopeControl():
	"""This class controls the LX200 Telescope over a serial connection."""

	def calibrate(self):
		"""This is the calibration method, this is called in the 
		__init__ method and can be called to reset the zeroes on
		the telescope."""
		self.send(chr(0x06))
		self.initialMode=self.read(1)	
		
		print "Inital Mode: ",self.initialMode
		
		#put telescope into land mode
		self.send("AL")

		self.zeroAltitude=0
		self.zeroAltitude=self.getAltitude()
		self.zeroAzimuth=0
		self.zeroAzimuth=self.getAzimuth()
	def send(self,message):
		"""This send a message to the LX200 over the classes internal
		serial variable."""
		#messages to the LX200 take to format of :SOME_MESSAGE# with a
		#hash (#) as a terminator this method sends a hash then colon (:)
		#to ensure any unterminated messages are no longer pending. this
		#could have the side affect of this method running a command if
		#the start of a message was sent but never terminated. EX ":Q" was
		#sent.
		self.ser.write("#:"+message+"#")
	def read(self,howMuch="#"):
		"""Listens to the serial connection for incoming chars. If howMuch
		is a number, if reads that many numbers then returns, if howMuch is
		a hash (#) it returns all the char up to a hash."""
		if howMuch=="#":
			return self.readUntilHash()
		elif isinstance(howMuch,int):
			return self.ser.read(howMuch)
	def readAngle(self):
		"""This method assumes that a command has been sent that requests
		an angle. It reads from the serial connection and converts the
		response into a float."""
		return self.convertToDecimal(self.read())
	def getAltitude(self):
		"""Sends the Get Altitude command (GA) and returns a float of the
		altitude angle."""
		self.send("GA")
		return (self.readAngle()-self.zeroAltitude+180)%360-180
	def getAzimuth(self):
		"""Sends the Get Azimuth command (GZ) and returns a float of the
		azimuth angle."""
		self.send("GZ")
		return (self.readAngle()-self.zeroAzimuth+180)%360-180
	def setSpeed(self,speed=0):
		"""Sets the speed of the telescope to a number between 1 and 4, if
		zero is passed stop for each direction is called. The speeds
		correspond as such 1: Guide Rate (RG), 2: Center Rate (RC),
		3: Find Rate (RM), 4: Slew Rate (RS)."""
		if speed==1:
			self.send("RG")
		elif speed==2:
			self.send("RC")
		elif speed==3:
			self.send("RM")
		elif speed==4:
			self.send("RS")
		else:
			self.stop("nsew")
			self.send("Q")
		self.currentSpeed=speed
	def stop(self,dir):
		"""Sends stop to all directions in string dir. For example if dir
		is "ns" it will stop north and south. (Sends :Qs# and :Qn#)."""
		for x in dir:
			self.send("Q"+x)
			try:
				self.currentMotion[x]=False
			except AttributeError:
				self.currentMotion={x:False}
	def move(self,dir):
		"""Sends move to all directions in string dir. For example if dir
		is "ne" it will move north and east. (Sends :Mn# and :Me#)."""
		for x in dir:
			self.send("M"+x)
			try:
				self.currentMotion[x]=True
			except AttributeError:
				self.currentMotion={x:True}
	def __init__(self,serialDev):
		"""Init method called on object initialization."""
		self.ser=serial.Serial(serialDev,timeout=2)
		self.calibrate()
	def readUntilHash(self):
		"""This function reads a response until a hash (#)
		char has been received."""
		got=""
		gotJustNow=self.ser.read()
		while gotJustNow!="#":
			got+=gotJustNow
			gotJustNow=self.ser.read()
		return got
	def convertToDecimal(self,s):
		"""This takes an ascii string as received from lx200 in format of
		sDD*MM where s is sign, DD is degrees and MM is minutes. * represents
		ASCII 223 (0xE9), the symbol the LX200 uses to separate degrees and
		minutes. It returns a float of the decimal degrees of the string."""
		s=s.split(chr(223))
		return float(s[0])+float(s[1])/60
	def shutdown(self):
		"""A cleanup method. It sets the LX200 back to whatever mode it was in
		at startup and stops all movement. It also closes the serial
		connection."""
		self.send("A"+self.initialMode)
		self.stop("nsew#")
		self.ser.close()
	def isClose(self,current,target,proximity):
		"""Returns True if the difference between `current` and `target` is less
		than `proximity`. Otherwise it returns False."""
		return abs(target-current)<=proximity
	def goTowards(self,current,target,options="ns"):
		"""Go in a direction from the string `options`. If `current` is less than
		`target` the direction will be options[0] otherwise the direction will be
		options[1]."""
		direction,notDirection=(options[0],options[1]) if target>current else (options[1],options[0])
		self.stop(notDirection)
		self.move(direction)
	def goAtSpeedUntilProximity(self,speed,proximity,targetAltitude,targetAzimuth):
		"""Move at target speed until altitude and azimuth are within target
		`proximity`. If either reaches `proximity` first, stop motion in that
		axis."""
		print "speed",speed
		self.setSpeed(speed)
		while targetAltitude!=None or targetAzimuth!=None:
			currentAltitude="Stopped"
			currentAzimuth="Stopped"
			if targetAltitude!=None:
				currentAltitude=self.getAltitude()
				if self.isClose(currentAltitude,targetAltitude,proximity):
					self.stop("ns")
					print "stopping altitude"
					targetAltitude=None
				else:
					self.goTowards(currentAltitude,targetAltitude,"ns")
			if targetAzimuth!=None:
				currentAzimuth=self.getAzimuth()
				if self.isClose(currentAzimuth,targetAzimuth,proximity):
					self.stop("we")
					print "stopping azimuth"
					targetAzimuth=None
				else:
					self.goTowards(currentAzimuth,targetAzimuth,"we")
			print self.currentMotion,currentAltitude,currentAzimuth
			sleep(0.5)
		sleep(0.5)
	def goTo(self,targetAltitude=None,targetAzimuth=None):
		"""Move at max speed until the altitude and azimuth of the telescope are
		whiten a proximity of of targetAltitude and targetAzimuth. Then drop speed
		and get them to new proximity. Repeat until speed is minimum."""
		print targetAltitude,targetAzimuth
		targetAltitude=(targetAltitude+180)%360-180
		targetAzimuth=(targetAzimuth+180)%360-180
		if not (-100<targetAltitude<100):
			targetAltitude=None
		self.goAtSpeedUntilProximity(4,6,targetAltitude,targetAzimuth)
		self.goAtSpeedUntilProximity(3,2,targetAltitude,targetAzimuth)
		self.goAtSpeedUntilProximity(2,0.1,targetAltitude,targetAzimuth)
		return "Success"