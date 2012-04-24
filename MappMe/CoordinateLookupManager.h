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

@protocol CoordinateLookupManagerDelegate
//Invoked when all operation in operation queue is completed succssfully.
- (void)allOperationFinished;
@end


@class Place;
@interface CoordinateLookupManager : NSObject {
    //Async request queue. Exposed to public
    //so we can cancel requests and see what's the left requests.
    NSOperationQueue *queue;
    id<CoordinateLookupManagerDelegate> delegate;
}

@property (nonatomic, retain)  NSOperationQueue *queue;
@property (retain) id<CoordinateLookupManagerDelegate> delegate;

- (void)lookupLocation:(Place*)place;
+ (id)sharedManager;
@end