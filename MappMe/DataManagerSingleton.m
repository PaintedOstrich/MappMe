//
//  DataManagerSingleton.m
//  MappMe
//
//  Created by Parker Spielman on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataManagerSingleton.h"

// If you want to know about the synchronous thread safe structure,
// Read here: http://blog.jh-lim.com/2011/09/implementing-a-singleton-in-ios/

@implementation DataManagerSingleton

@synthesize placeContainer;
@synthesize userInfoLog;
@synthesize peopleContainer;
@synthesize fbImageHandler;

static DataManagerSingleton *mainDataManager = nil;

+(DataManagerSingleton *) sharedInstance {
    
    NSLog (@"sharedInstance called.");
    
    if (nil != mainDataManager) return mainDataManager;
    static dispatch_once_t pred;        // lock
    dispatch_once(&pred, ^{             // this code is at most once
        mainDataManager = [[DataManagerSingleton alloc] init];
    });
    
    return mainDataManager;
    
}

-(id)init{
    if (self = [super init]) {
        /*FIXME LAter:  accoutn for stored info*/
        placeContainer = [[PlaceContainer alloc] init];
        peopleContainer =[[PeopleContainer alloc] init];
        userInfoLog = [[UserInfoLog alloc] init];
        fbImageHandler = [[FacebookImageHandler alloc] init];
    }
    return self;
}

@end
