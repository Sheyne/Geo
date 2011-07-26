//
//  ShowAngle.m
//  Geo
//
//  Created by Sheyne Anderson on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShowAngle.h"


@implementation ShowAngle
@synthesize angle;
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	NSBezierPath* thePath = [NSBezierPath bezierPath];
	[thePath setLineWidth:1.0];
	[thePath moveToPoint:NSMakePoint(self.frame.size.width, 0.0)];
	double h=self.frame.size.height/sin(angle);
	[thePath lineToPoint:NSMakePoint(0.0, 0.0)];
	[thePath lineToPoint:NSMakePoint(h*cos(angle), self.frame.size.height)];
	[[NSColor textColor]set];
	[thePath stroke];
}

@end
