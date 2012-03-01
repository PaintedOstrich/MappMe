//
//  ViewController.m
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "MappMeAppDelegate.h"
#import "DebugLog.h"

@implementation LoginViewController{
    MappMeAppDelegate *delegate;
}
@synthesize permissions;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}
-(void)showLoggedIn{
    DebugLog(@"logged in");
    [self performSegueWithIdentifier:@"LoggedInSegue" sender:self];
}
-(IBAction)loginButtonPress{
    if (![[delegate facebook] isSessionValid]) {
        [[delegate facebook] authorize:permissions];
    }
    DebugLog(@"called login method");
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[delegate facebook] logout];
    
    permissions = [[NSArray alloc] initWithObjects:@"friends_hometown",@"friends_location",@"friends_work_history",@"friends_education_history", nil];
    [super viewWillAppear:animated];
    
    delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![[delegate facebook] isSessionValid]) {
        //Start animation for main screen
        DebugLog(@"logged out");
    } else {
        [self showLoggedIn];
    }
}
#pragma mark - FBSessionDelegate Methods
- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}
/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
    DebugLog(@"root view did login");
    [self storeAuthData:[[delegate facebook] accessToken] expiresAt:[[delegate facebook] expirationDate]];
    [self showLoggedIn];
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSLog(@"token extended");
    [self storeAuthData:accessToken expiresAt:expiresAt];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
   
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
    // Remove saved authorization information if it exists and it is
    // ok to clear it (logout, session invalid, app unauthorized)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
//    [self showLoggedOut];
}
/**
 * Called when the session has expired.
 */
- (void)fbSessionInvalidated {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Auth Exception"
                              message:@"Your session has expired."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil,
                              nil];
    [alertView show];
    [self fbDidLogout];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
