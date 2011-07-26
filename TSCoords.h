//
//  TSCoords.h
//  TestTelescopeController
//
//  Created by Sheyne Anderson on 6/9/11.
//  Copyright 2011 Sheyne Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TSCoords : NSObject {
	double altitude;
	double azimuth;
}
-(TSCoords*)initWithAltitude:(double)altitude azimuth:(double)azimuth;
+(TSCoords*)coordsWithAltitude:(double)altitude azimuth:(double)azimuth;
@property (assign) double altitude;
@property (assign) double azimuth;
@end
