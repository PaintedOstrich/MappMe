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

static DataManagerSingleton *mainDataManager = nil;

#pragma mark Singleton Methods
+ (id)sharedManager {
    @synchronized(self) {
        if (mainDataManager == nil)
            mainDataManager = [[self alloc] init];
    }
    return mainDataManager;
}


-(id)init{
    if (self = [super init]) {
        /*FIXME LAter:  accoutn for stored info*/
        placeContainer = [[PlaceContainer alloc] init];
        peopleContainer =[[PeopleContainer alloc] init];
        userInfoLog = [[UserInfoLog alloc] init];
    }
    return self;
}

-(void) clearAllData
{
  [placeContainer clearData];
  [peopleContainer clearData];
}

@end
