//
//  TelescopeController.h
//  Geo
//
//  Created by Sheyne Anderson on 6/6/11.
//  Copyright 2011 Sheyne Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Python/Python.h>
#import "TSCoords.h"

@interface TelescopeController : NSObject {
	bool moving;
	PyObject *tele_goTo;
}
//@property (assign, nonatomic) double altitude
@property (readonly) bool moving;
-(bool)goToAltitude:(double)altitude azimuth:(double)azimuth;
-(TelescopeController*)initWithComm:(NSString*)comm;
@end
