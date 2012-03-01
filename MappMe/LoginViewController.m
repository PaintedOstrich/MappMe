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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)showLoggedIn{
    DebugLog(@"performing selector in loginviewcontroller");
    [self performSegueWithIdentifier:@"LoggedInSegue" sender:self];
}

-(IBAction)loginButtonPress{
    if (![[delegate facebook] isSessionValid]) {
        [[delegate facebook] authorize:[delegate permissions]];
    }else{
        [self showLoggedIn];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];

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
//    [[delegate facebook] logout];
    
//
//    [super viewWillAppear:animated];
//    
//    delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
//    if (![[delegate facebook] isSessionValid]) {
//        //Start animation for main screen
//        DebugLog(@"logged out");
//    } else {
//        DebugLog(@"logged in");
//        [self showLoggedIn];
//    }
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
