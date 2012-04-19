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

@interface DataManagerSingleton : NSObject{
    PlaceContainer *placeContainer;
    PeopleContainer *peopleContainer;
    UserInfoLog *userInfoLog;
}

@property (nonatomic, retain) PlaceContainer *placeContainer; 
@property (nonatomic, retain) UserInfoLog  *userInfoLog; 
@property (nonatomic, retain) PeopleContainer *peopleContainer;

+ (id)sharedManager;
//Called when we log out/switch user to clear all data.
-(void) clearAllData;
@end
