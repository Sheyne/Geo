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

void strip(char * str){
	/*
	 Takes a string and strips of trailing whitespace.
	 */
	int end=strlen(str)-1;
	while (str[end]=='\n'||str[end]=='\r'||str[end]==' ')
		end--;
	str[end+1]='\0';
}

@implementation GeoAppDelegate



@synthesize deviceList;
@synthesize window;
@synthesize angle;
@synthesize latself;
@synthesize lattarget;
@synthesize lonself;
@synthesize lontarget;
@synthesize altself;
@synthesize alttarget;
@synthesize distto;
@synthesize angto;
@synthesize heading;
@synthesize sheading;
@synthesize callsigns;
@synthesize targetLogFile;
@synthesize com;
@synthesize generalSpeed;
@synthesize generalRate;
@synthesize generalHeading;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	//NSString *s=[[NSString alloc]initWithString:@"HI"];
	[self calculate:nil];
	queue=[[UKKQueue alloc] init];
	[queue setDelegate:self];
	rt=[[ReceiverThread alloc] init];
	rt.delegate=self;
	[NSThread detachNewThreadSelector:@selector(start) toTarget:rt withObject:nil];
}
-(void)selectTargetLogFile:(id)sender{
	[FileChooser getFileForTextField:targetLogFile];
	[queue addPath:targetLogFile.stringValue];
	[self watcher:nil receivedNotification:nil forPath:targetLogFile.stringValue];
}
-(IBAction)openCOMDevice:(id)sender{
	if ([com.stringValue isEqualToString:@""]) {
		NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/dev" error:nil];
		NSMutableString*comms=[NSMutableString stringWithCapacity:40];
		for(NSString* x in dirContents)
			if ([x hasPrefix:@"tty.PL2303-"]) {
				[comms appendFormat:@"/dev/%@\n",x];
			}
		[[NSAlert alertWithMessageText:@"No device entered, here are detected devices." defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:comms] runModal];
	}else
		tele=[[TelescopeController alloc]initWithComm:com.stringValue];
}
-(void)receivedMessage:(NSString *)message{
	NSLog(@"Message: %@",message);
	if([message hasPrefix:@"Parsing failed:"])
		return;
	NSArray *lines=[message componentsSeparatedByString:@"\n"];
	for(NSString *line in lines){
		NSArray * mes=[line componentsSeparatedByString:@":"];
		if ([mes count]==2) {
			NSString *key=[NSString stringWithFormat:@"%@%@",@"Self",[mes objectAtIndex:0]];
			NSTextField*field=[self textFieldForKey:key];
			if (field)
				[field setStringValue:[mes objectAtIndex:1]];
		}
	}
	[self calculate:nil];
}
-(void)watcher:(UKKQueue*)kq receivedNotification:(NSString *)note forPath:(NSString*)path{
	FILE*fp;
	if(!(fp=fopen([path UTF8String], "r")))
		return;
	if (note ==UKFileWatcherDeleteNotification) {
		[queue addPath:path];	
	}
	#define GEO_LOG_MAX_LINE_LENGTH 400
	char buff1[GEO_LOG_MAX_LINE_LENGTH];
	char buff2[GEO_LOG_MAX_LINE_LENGTH];
	char *buff, *oldbuff, *tmpbuff;
	buff=buff1;
	oldbuff=buff2;
	int buffsize=GEO_LOG_MAX_LINE_LENGTH;
	//scan to end of file
	while(fgets(oldbuff, buffsize, fp)){
		tmpbuff=oldbuff;
		oldbuff=buff;
		buff=tmpbuff;
	}
	fclose(fp);
	//oldbuff, 2nd to last line
	//buff last line
	strip(oldbuff);
	strip(buff);
	printf("%s\n%s\n",oldbuff,buff);
	fap_packet_t*packet;
	fap_init();
	packet=fap_parseaprs(buff, strlen(buff), 0);
	if ( packet->error_code )
	{
		fap_explain_error(*packet->error_code, buff);
		printf("Failed to parse packet, %s\n", buff);
	}
	else if ( packet->src_callsign )
	{
		NSString *call=[[NSString stringWithUTF8String:packet->src_callsign] lowercaseString];
		bool cont=FALSE;
		for(NSString*callsign in [callsigns.stringValue componentsSeparatedByString:@","]){
			if ([call hasPrefix:[callsign lowercaseString]]){
				cont=YES;
				break;
			}
		}
		if(!cont)
			return;
		
		// "# MS_SINCE_EPOCH %a %b %d %H:%M:%S %Z %Y"
		//extract MS_SINCE_EPOCH
		//skip past "# " at start of time string
		oldbuff+=2;
		int end=0;
		//stop at first space
		while (oldbuff[end]!=' ')
			end++;
		oldbuff[end]='\0';
		
		printf("\"%s\"",buff);
		//timeDifference is the time since the last packet as expressed in seconds
		time_t tim=(time_t)atoi(oldbuff);
		time_t timeDifference=tim-oldPacket.time;
		oldbuff-=2;
		
		if(oldPacket.time!=0){
			struct tm *ts;
			ts = gmtime(&timeDifference);
			strftime(oldbuff, GEO_LOG_MAX_LINE_LENGTH, "%H:%M:%S", ts);
		}else {
			strcpy(oldbuff,"This is the first packet.");
		}
		
		printf("Time since last packet: %s\n",oldbuff);
		if (packet->latitude&&packet->longitude&&packet->altitude){
			/*
			 
			 
			if(oldPacket.time!=0){
				if (oldPacket.altitude)
					self.generalRate.doubleValue=(*packet->altitude-oldPacket.altitude)/timeDifference;
				SphericalPoint *oldLocation=[[[SphericalPoint alloc] initWithLatitude:oldPacket.latitude
																		   longitude:oldPacket.longitude
																			altitude:oldPacket.altitude] autorelease];
				SphericalPoint *newLocation=[[[SphericalPoint alloc] initWithLatitude:*packet->latitude
																		   longitude:*packet->longitude
																			altitude:*packet->altitude] autorelease];
				[oldLocation findTarget:newLocation];
				if(packet->altitude&&oldPacket.altitude)
					self.generalRate.doubleValue=(*packet->altitude-oldPacket.altitude)/timeDifference;
				oldPacket.altitude=*packet->altitude;
				self.generalHeading.heading=oldLocation.headingFromSelfToTarget+M_PI/2;
				[self.generalHeading setNeedsDisplay:YES];
				
			}
			if(packet->speed)
				self.generalSpeed.doubleValue=*packet->speed;
			oldPacket=(GEOData){0,0,0,0};
			oldPacket.altitude=*packet->altitude;
			oldPacket.latitude=*packet->latitude;
			oldPacket.longitude=*packet->longitude;
			oldPacket.time=tim;
			*/
			lattarget.doubleValue=*packet->latitude;
			lontarget.doubleValue=*packet->longitude;
			alttarget.doubleValue=*packet->altitude;
		}
		[self calculate:nil];
	}
	fap_free(packet);
	
	fap_cleanup();
}
-(IBAction)calculate:(id)sender{
	SphericalPoint *base=[[SphericalPoint alloc] initWithLatitude:latself.doubleValue longitude:lonself.doubleValue	altitude:altself.doubleValue];
	SphericalPoint *target=[[SphericalPoint alloc] initWithLatitude:lattarget.doubleValue longitude:lontarget.doubleValue altitude:alttarget.doubleValue];
	[base findTarget:target];
	distto.doubleValue=base.distanceBetweenSelfAndTarget;
	angto.doubleValue=base.angleFromLevelToTarget*180/M_PI;
	heading.doubleValue=base.headingFromSelfToTarget*180/M_PI;
	sheading.heading=base.headingFromSelfToTarget+M_PI/2;
	[sheading setNeedsDisplay:YES];
	angle.angle=base.angleFromLevelToTarget;
	[tele goToAltitude:base.angleFromLevelToTarget*180/M_PI azimuth:(base.headingFromSelfToTarget*180/M_PI)+180];
	[angle setNeedsDisplay:YES];
	[base release];
	[target release];
}
-(IBAction)refreshDeviceList:(id)sender{
	NSLog(@"I was called");
	if(devices){
		for(NSMenuItem*item in devices)
			[deviceList removeItem:item];
		[devices removeAllObjects];
	}else {
		devices=[[NSMutableSet alloc]init];		
	}
	NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/dev" error:nil];
	for(NSString* x in dirContents)
		if ([x hasPrefix:@"tty.PL2303-"]) {
			NSMenuItem *item=[deviceList addItemWithTitle:x action:@selector(setTelescopeDevice:) keyEquivalent:nil];
			[devices addObject:item];
			NSLog(@"%s",x);
			//[comms appendFormat:@"/dev/%@\n",x];
		}
	
}
-(NSTextField*)textFieldForKey:(NSString *)key{
	if([key isEqualToString: @"SelfLatitude"]){
		return latself;
	}
	if([key isEqualToString: @"SelfLongitude"]){
		return lonself;
	}
	if([key isEqualToString: @"SelfAltitude"]){
		return altself;
	}
	if([key isEqualToString: @"TargetLatitude"]){
		return lattarget;
	}
	if([key isEqualToString: @"TargetLongitude"]){
		return lontarget;
	}
	if([key isEqualToString: @"TargetAltitude"]){
		return alttarget;
	}
	return nil;
}
-(void)dealloc{
	[queue release];
	[rt release];
	[rt stop];
	[guiObjects release];
	[super dealloc];
}

@end