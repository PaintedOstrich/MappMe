//
//  AppDelegate.m
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MappMeAppDelegate.h"
#import "LoginViewController.h"

static NSString * kAppId = @"291279594218895";
@implementation MappMeAppDelegate

@synthesize window = _window;
@synthesize facebook;

@synthesize placeIdMapping;
@synthesize personNameAndIdMapping;
@synthesize userInfoLog;
@synthesize peopleContainer;
@synthesize fbImageHandler;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*FIXME LAter:  accoutn for stored info*/
    personNameAndIdMapping = [[PersonNameAndIdMapping alloc] init];
    placeIdMapping = [[PlaceIdMapping alloc] init];
    peopleContainer =[[PeopleContainer alloc] init];
    userInfoLog = [[UserInfoLog alloc] init];
    fbImageHandler = [[FacebookImageHandler alloc] init];
    
    
    LoginViewController *controller = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"LoginController"];
    facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:controller];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }

    if(![facebook isSessionValid]){ 
        self.window.rootViewController = controller;
        [self.window makeKeyAndVisible];
    }
    return YES;
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url]; 
}
	
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
