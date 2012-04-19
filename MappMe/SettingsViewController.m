//
//  SettingsViewController.m
//  MappMe
//
//  Created by #BAL on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "LoginViewController.h"
#import "MappMeAppDelegate.h"
#import "DataManagerSingleton.h"

@implementation SettingsViewController {
    MappMeAppDelegate *delegate;
}

/*
 * Navigate back to login screen when logout button is clicked
 * (TODO) move this method into settings page
 */
-(IBAction)logoutBtnTapped{
    [[DataManagerSingleton sharedManager] clearAllData];
    LoginViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginController"];
    [[delegate facebook] setSessionDelegate:controller];
    [[delegate facebook] logout];
    delegate.window.rootViewController = controller;
    [delegate.window makeKeyAndVisible];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
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
