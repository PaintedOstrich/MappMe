//
//  AppDelegate.h
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "DataManagerSingleton.h"
#import <dispatch/dispatch.h>

@interface MappMeAppDelegate : NSObject <UIApplicationDelegate>{
    Facebook *facebook;
    DataManagerSingleton *mainDataManager;
    dispatch_queue_t backgroundQueue;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) DataManagerSingleton *mainDataManager;

@property (nonatomic)  dispatch_queue_t backgroundQueue;

@end
