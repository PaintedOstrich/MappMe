//
//  MainViewController.m
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "DebugLog.h"
#import "MappMeAppDelegate.h"
#import "LoginViewController.h"

@implementation MainViewController{
    MappMeAppDelegate *delegate;
    MBProgressHUD *HUD;
}

@synthesize mapView;

-(IBAction)logoutBtnTapped{
    LoginViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginController"];
    [[delegate facebook] setSessionDelegate:controller];
    [[delegate facebook] logout];
    delegate.window.rootViewController = controller;
    [delegate.window makeKeyAndVisible];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)someTask {
    // Do something usefull in here instead of sleeping ...
    sleep(3);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    
    // Show the HUD while the provided method executes in a new thread
    [HUD showWhileExecuting:@selector(someTask) onTarget:self withObject:nil animated:YES];
}

-(void) viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:TRUE animated:TRUE];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
