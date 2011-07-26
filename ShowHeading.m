//
//  ShowHeading.m
//  Geo
//
//  Created by Sheyne Anderson on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShowHeading.h"


@implementation ShowHeading
@synthesize heading;
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	NSDictionary*d=[NSDictionary dictionaryWithObject:[NSColor textColor]
											   forKey:NSForegroundColorAttributeName];
	[@"N" drawAtPoint:NSMakePoint( 46.5, 85) withAttributes:d];
	[@"S" drawAtPoint:NSMakePoint( 45, 0) withAttributes:d];
	[@"E" drawAtPoint:NSMakePoint( 90, 43) withAttributes:d];
	[@"W" drawAtPoint:NSMakePoint( 1, 43) withAttributes:d];
	NSBezierPath* thePath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(20,20,60,60)];
	[thePath setLineWidth:1.0];
	[thePath moveToPoint:NSMakePoint(50,50)];
	[thePath lineToPoint:NSMakePoint(50-50*cos(heading),50+50*sin(heading))];
	[[NSColor textColor]set];
	[thePath stroke];	
}

@end
