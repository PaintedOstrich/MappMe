//
//  AppDelegate.h
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface MappMeAppDelegate : NSObject <UIApplicationDelegate, FBSessionDelegate>{
    Facebook *facebook;
     NSArray *permissions;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) NSArray *permissions;

@end
