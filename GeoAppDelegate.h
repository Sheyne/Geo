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

@class JSONDecoder;

@interface GeoAppDelegate : NSObject <NSApplicationDelegate, TCPListener> {
    NSWindow *window;
	NSNumber *_port;
	NSString *_server;
	JSONDecoder * _decoder;
	TCP *tcp;
	NSString *_nameOfBase;
	SphericalPoint * _selfPoint;
	NSMutableDictionary * _targetPoints;
}


@property (assign) IBOutlet NSWindow *window;
@property (retain) NSNumber *port;
@property (retain) NSString *server;
@property (retain) JSONDecoder * decoder;
@property (retain) SphericalPoint * selfPoint;
@property (retain) NSMutableDictionary * targetPoints;
@property (retain) NSString *nameOfBase;


@end
