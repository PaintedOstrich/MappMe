//
//  AppDelegate.h
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "PlaceContainer.h"
#import "PeopleContainer.h"
#import "UserInfoLog.h"
#import "FacebookImageHandler.h"
#import <dispatch/dispatch.h>

@interface MappMeAppDelegate : NSObject <UIApplicationDelegate>{
    Facebook *facebook;
    PlaceContainer *placeContainer;
    PeopleContainer *peopleContainer;
    UserInfoLog *userInfoLog;
    FacebookImageHandler *fbImageHandler;
    dispatch_queue_t backgroundQueue;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) PlaceContainer *placeContainer; 
@property (nonatomic, retain) UserInfoLog  *userInfoLog; 
@property (nonatomic, retain) PeopleContainer *peopleContainer;
@property (nonatomic, retain) FacebookImageHandler *fbImageHandler;
@property (nonatomic)  dispatch_queue_t backgroundQueue;

@end
