//
//  GeoAppDelegate.h
//  Geo
//
//  Created by Sheyne Anderson on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <TCP/TCP.h>


typedef struct{
	time_t time;
	double latitude;
	double longitude;
	double altitude;
}GEOData;

@interface GeoAppDelegate : NSObject <NSApplicationDelegate, TCPListener> {
    NSWindow *window;
	NSNumber *_port;
	NSString *_server;
	TCP *tcp;
}


@property (assign) IBOutlet NSWindow *window;
@property (retain) NSNumber *port;
@property (retain) NSString *server;

@end
