//
//  TSCoords.m
//  TestTelescopeController
//
//  Created by Sheyne Anderson on 6/9/11.
//  Copyright 2011 Sheyne Anderson. All rights reserved.
//

#import "TSCoords.h"


@implementation TSCoords
@synthesize altitude;
@synthesize azimuth;

-(TSCoords*)initWithAltitude:(double)_altitude azimuth:(double)_azimuth{
	self.altitude=_altitude;
	self.azimuth=_azimuth;
	return self;
}
+(TSCoords*)coordsWithAltitude:(double)altitude azimuth:(double)azimuth{
	return [[[TSCoords alloc]initWithAltitude:altitude azimuth:azimuth]autorelease];
}
@end
