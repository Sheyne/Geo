//
//  TelescopeController.m
//  Geo
//
//  Created by Sheyne Anderson on 6/6/11.
//  Copyright 2011 Sheyne Anderson. All rights reserved.
//

#import "TelescopeController.h"


@interface TelescopeController ()

-(void)goTo:(TSCoords*)cords;

@end

@implementation TelescopeController

@synthesize moving;


-(TelescopeController*)initWithComm:(NSString*)comm{
	if([super init]){
		Py_Initialize();
		const char* lx200=[[[NSBundle mainBundle] pathForResource:@"lx200" ofType:@"py"] UTF8String];
		FILE* fp=fopen(lx200, "r");
		PyRun_SimpleFileExFlags(fp,lx200,0,NULL);
		PyObject* main_module = PyImport_AddModule("__main__");
		PyObject *TelescopeControl = PyObject_GetAttrString(main_module, "TelescopeControl");
		
		if(TelescopeControl && PyCallable_Check(TelescopeControl)){
			//calibrate
			/*
			 Telescope must be calibrated.
			 Before calibrating please:
			 1. put telescope into land mode
			 2. when you are looking at the faceplate, you should be facing north
			 3. set telescope to 0 altitude and 0 azimuth
			 
			 Press enter to begin calibration
			 */
			
			// theargs[0] = "/dev/tty.PL2303-000013FD"

			PyObject *theargs = PyTuple_New(1);
			NSLog(@"%@",comm);
			PyTuple_SetItem(theargs, 0, PyString_FromString([comm UTF8String]));
			
			PyObject *tele = PyObject_CallObject(TelescopeControl, theargs);
			tele_goTo = PyObject_GetAttrString(tele, "goTo");			
		}
		
	}
	return self;
}
-(bool)goToAltitude:(double)altitude azimuth:(double)azimuth{
	NSLog(@"goToAltitude: %f azimuth: %f",altitude,azimuth);
	if (isnan(altitude))
		altitude=0;
	if (isnan(azimuth))
		azimuth=0;
	if (!moving)
		[self performSelectorInBackground:@selector(goTo:) withObject:[TSCoords coordsWithAltitude:altitude azimuth:azimuth]];
	return !moving;
}
-(void)goTo:(TSCoords*)coords{
	NSAutoreleasePool *arPool = [[NSAutoreleasePool alloc] init];
	[coords retain];
	moving=YES;
	PyObject *theargs = PyTuple_New(2);
	PyTuple_SetItem(theargs, 0, PyLong_FromDouble(coords.altitude));
	PyTuple_SetItem(theargs, 1, PyLong_FromDouble(coords.azimuth));
	
	PyObject *result = PyObject_CallObject(tele_goTo, theargs);
	
	if(result != NULL){
		printf("Result of call: %s\n", PyString_AsString(result));
	}
	moving=NO;
	[coords release];
	[arPool release];
}
-(void)dealloc{
	Py_Finalize();
	[super dealloc];
}
@end
