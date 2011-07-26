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

@implementation GeoAppDelegate



@synthesize window;
@synthesize port=_port;
@synthesize server=_server;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.server=@"localhost";
	[self addObserver:self forKeyPath:@"port" options:NSKeyValueObservingOptionNew context:NULL];
	self.port=[NSNumber numberWithInt:54730];
	tcp=[[TCP alloc] init];
	tcp.delegate=self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	[tcp connectToServer:self.server onPort:self.port.intValue];
	NSLog(@"the new port is: %@",self.port);
}

-(void)receivedMessage:(NSData *)message socket:(CFSocketRef)socket{
	NSLog(@"recieved message: %s", message.bytes);
}

@end