//
//  GeoAppDelegate.h
//  Geo
//
//  Created by Sheyne Anderson on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef struct{
	time_t time;
	double latitude;
	double longitude;
	double altitude;
}GEOData;

@interface GeoAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSNumber *_port;
}


@property (assign) IBOutlet NSWindow *window;
@property (retain) NSNumber *port;

@end
