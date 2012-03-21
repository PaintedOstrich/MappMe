//
//  AppDelegate.h
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "PlaceIdMapping.h"
#import "PersonNameAndIdMapping.h"
#import "PeopleContainer.h"
#import "UserInfoLog.h"
#import "FacebookImageHandler.h"

@interface MappMeAppDelegate : NSObject <UIApplicationDelegate>{
    Facebook *facebook;
    PersonNameAndIdMapping *personNameAndIdMapping;
    PlaceIdMapping *placeIdMapping;
    PeopleContainer *peopleContainer;
    UserInfoLog *userInfoLog;
    FacebookImageHandler *fbImageHandler;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) Facebook *facebook;

@property (nonatomic, retain) PersonNameAndIdMapping *personNameAndIdMapping;
@property (nonatomic, retain) PlaceIdMapping *placeIdMapping; 
@property (nonatomic, retain) UserInfoLog  *userInfoLog; 
@property (nonatomic, retain) PeopleContainer *peopleContainer;
@property (nonatomic, retain) FacebookImageHandler *fbImageHandler;

@end
