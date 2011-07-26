//
//  GeoAppDelegate.h
//  Geo
//
//  Created by Sheyne Anderson on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ShowAngle.h"
#import "ShowHeading.h"
#import "ReceiverThread.h"
#import "UKKQueue.h"
#import "FileChooser.h"
#import "TelescopeController.h"

typedef struct{
	time_t time;
	double latitude;
	double longitude;
	double altitude;
}GEOData;

@interface GeoAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSTextField *latself;
	NSTextField *lattarget;
	NSTextField *lonself;
	NSTextField *lontarget;
	NSTextField *altself;
	NSTextField *alttarget;
	NSTextField *distto;
	NSTextField *angto;
	NSTextField *heading;
	NSTextField *callsigns;
	NSTextField *targetLogFile;
	ShowAngle* angle;
	UKKQueue* queue;
	ShowHeading* sheading;
	NSDictionary *guiObjects;
	ReceiverThread*rt;
	NSArray*allowedCallSigns;
	TelescopeController *tele;
	NSTextField *com;
	ShowHeading *generalHeading;
	NSTextField *generalRate;
	NSTextField *generalSpeed;
	GEOData oldPacket;
	NSMenu *deviceList;
	NSMutableSet*devices;
}


@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet ShowAngle *angle;
@property (assign) IBOutlet ShowHeading *sheading;
@property (assign) IBOutlet NSTextField *latself;
@property (assign) IBOutlet NSTextField *lattarget;
@property (assign) IBOutlet NSTextField *lonself;
@property (assign) IBOutlet NSTextField *lontarget;
@property (assign) IBOutlet NSTextField *altself;
@property (assign) IBOutlet NSTextField *alttarget;
@property (assign) IBOutlet NSTextField *distto;
@property (assign) IBOutlet NSTextField *angto;
@property (assign) IBOutlet NSTextField *heading;
@property (assign) IBOutlet NSTextField *callsigns;
@property (assign) IBOutlet NSTextField *targetLogFile;
@property (assign) IBOutlet NSTextField *com;
@property (assign) IBOutlet ShowHeading *generalHeading;
@property (assign) IBOutlet NSTextField *generalRate;
@property (assign) IBOutlet NSTextField *generalSpeed;
@property (assign) IBOutlet NSMenu *deviceList;

-(void)watcher:(UKKQueue*)kq receivedNotification:(NSString *)note forPath:(NSString*)path;
-(void)receivedMessage:(NSString*)message;
-(NSTextField*)textFieldForKey:(NSString*)key;
-(IBAction)calculate:(id)sender;
-(IBAction)selectTargetLogFile:(id)sender;
-(IBAction)openCOMDevice:(id)sender;
-(IBAction)refreshDeviceList:(id)sender;

@end
