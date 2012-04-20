//
//  CoordinateLookupManager.h
//  MappMe
//
//  Created by Parker Spielman on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CoordPairsHelper.h"

@class Place;
@interface CoordinateLookupManager : NSObject

- (void)lookupLocation:(Place*)place;
+ (id)sharedManager;
@end