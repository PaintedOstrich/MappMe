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
@interface CoordinateLookupManager : NSObject {
    //Async request queue. Exposed to public
    //so we can cancel requests and see what's the left requests.
    NSOperationQueue *queue;
    //Track if the Operation Queue is started.
    BOOL isStarted;
}

@property (nonatomic, retain)  NSOperationQueue *queue;
@property  BOOL isStarted;

//Will start the NSOperation queue.
- (void) startOperations;
- (void)lookupLocation:(Place*)place;
+ (id)sharedManager;
@end