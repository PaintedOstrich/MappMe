//
//  DataManagerSingleton.h
//  MappMe
//
//  Created by Parker Spielman on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaceContainer.h"
#import "PeopleContainer.h"
#import "UserInfoLog.h"
#import "FacebookImageHandler.h"

@interface DataManagerSingleton : NSObject{
    PlaceContainer *placeContainer;
    PeopleContainer *peopleContainer;
    UserInfoLog *userInfoLog;
    FacebookImageHandler *fbImageHandler;
}

@property (nonatomic, retain) PlaceContainer *placeContainer; 
@property (nonatomic, retain) UserInfoLog  *userInfoLog; 
@property (nonatomic, retain) PeopleContainer *peopleContainer;
@property (nonatomic, retain) FacebookImageHandler *fbImageHandler;

+ (id)sharedManager;
@end
