//
//  GeoAppDelegate.m
//  Geo
//
//  Created by Sheyne Anderson on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "SphericalPoint.h"
#import "GeoAppDelegate.h"
#include "/usr/local/include/fap.h"
#import "JSONKit.h"

NSString*reconnectContext=@"should reconnect context";
NSString*updatePositionContext=@"should update position context";

@implementation GeoAppDelegate



@synthesize window;
@synthesize port=_port;
@synthesize server=_server;
@synthesize decoder=_decoder;
@synthesize selfPoint=_selfPoint;
@synthesize targetPoints=_targetPoints;
@synthesize nameOfBase=_nameOfBase;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.decoder=[JSONDecoder decoder];
	self.nameOfBase=@"D710";
	self.targetPoints=[NSMutableDictionary dictionaryWithCapacity:3];
	tcp=[[TCP alloc] init];
	tcp.delegate=self;
	self.server=@"localhost";
	[self addObserver:self forKeyPath:@"port"   options:NSKeyValueObservingOptionNew context:reconnectContext];
	[self addObserver:self forKeyPath:@"server" options:NSKeyValueObservingOptionNew context:reconnectContext];
	[self addObserver:self forKeyPath:@"selfPoint"    options:NSKeyValueObservingOptionNew context:updatePositionContext];
	self.port=[NSNumber numberWithInt:54730];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if (context==reconnectContext) {
		[tcp connectToServer:self.server onPort:self.port.intValue];
		NSLog(@"the new port is: %@",self.port);		
	}else if(context==updatePositionContext)
		if (self.selfPoint)
			if(self.targetPoints.count>0){
				NSMutableDictionary *send=[NSMutableDictionary dictionaryWithCapacity:self.targetPoints.count];
				[self.targetPoints enumerateKeysAndObjectsUsingBlock:^(id key, id targetPoint, BOOL *stop) {
					[self.selfPoint findTarget:targetPoint];
					double distto, angto, heading;
					distto=self.selfPoint.distanceBetweenSelfAndTarget;
					angto=self.selfPoint.angleFromLevelToTarget*180/M_PI;
					heading=self.selfPoint.headingFromSelfToTarget*180/M_PI;
					NSMutableDictionary *obj=[NSMutableDictionary dictionaryWithCapacity:3];
					NSNumber * num;
					if (!isnan(distto)) {
						num=[NSNumber numberWithDouble:distto];
						[obj setObject:num forKey:@"distance"];
					}
					if (!isnan(angto)) {
						num=[NSNumber numberWithDouble:angto];
						[obj setObject:num forKey:@"altitude angle"];
					}
					if (!isnan(heading)){
						num=[NSNumber numberWithDouble:heading];
						[obj setObject:num forKey:@"azimuth"];
					}
					[send setObject:obj forKey:key];
				}];
				NSLog(@"encoding: %@",send);
				NSData *jsonData;
				if ((jsonData=[send JSONData])) {
					[tcp send:jsonData];
				}
			}
}

SphericalPoint *pointForPacket(id packet);
SphericalPoint *pointForPacket(id packet){
	@try {
		return [[[SphericalPoint alloc] initWithPhi:[[packet objectForKey:@"latitude"] doubleValue] theta:[[packet objectForKey:@"longitude"] doubleValue] rho:[[packet objectForKey:@"altitude"] doubleValue]] autorelease];
	}
	@catch (NSException *exception) {
		NSLog(@"Missing Lat/lon/alt");
		return nil;
	}
}


-(void)receivedMessage:(NSData *)message socket:(CFSocketRef)socket{
	[[self.decoder objectWithData:message] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		SphericalPoint *pnt;
		if ((pnt=pointForPacket(obj))) {
			if([self.nameOfBase isEqual:key]){
				self.selfPoint=pnt;
			}else{
				[self.targetPoints setObject:pnt forKey:key];
				[self observeValueForKeyPath:@"targetPoints" ofObject:self.targetPoints change:nil context:updatePositionContext];
			}
		}
		NSLog(@"%@: alt: %@ lat: %@ lon: %@",key, [obj objectForKey:@"altitude"], [obj objectForKey:@"latitude"], [obj objectForKey:@"longitude"]);
		}];
}
-(void)connected{
	NSLog(@"yay");
}

@end