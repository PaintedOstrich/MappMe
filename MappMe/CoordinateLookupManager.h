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
//For MainViewController to put up the loading banner at the bottom.
- (void)someOperationAdded;
//Invoked when all operation in operation queue is completed succssfully.
- (void)allOperationFinished;
@end


@class Place;
@interface CoordinateLookupManager : NSObject {
    id<CoordinateLookupManagerDelegate> delegate;
}

@property (retain) id<CoordinateLookupManagerDelegate> delegate;

- (void)lookupLocation:(Place*)place;
+ (id)sharedManager;

//Called when the app is becoming inactive(going to background)
//It will stop all outgoing nsoperations.
-(void) haltOperations;
-(void) resumeOperations;
-(void) cancelAllOperations;
@end