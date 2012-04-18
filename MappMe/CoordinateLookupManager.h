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

@interface CoordinateLookupManager : NSObject

- (void)lookupLocation:(NSString*)locationStr successCB:(void (^)(CoordPairsHelper*))successCB failureCB:(void (^)(NSError *error))failureCB;
+ (id)sharedManager;
@end