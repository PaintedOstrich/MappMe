//
//  SettingsMenuController.m
//  MappMe
//
//  Created by Di Peng on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsMenuController.h"
#import "MappMeAppDelegate.h"

@interface SettingsMenuController ()

@end

@implementation SettingsMenuController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(IBAction)logoutBtnPressed:(id)sender
{
    MappMeAppDelegate* delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[delegate facebook] logout];

    [[[self parentViewController] navigationController] popToRootViewControllerAnimated:YES];
}

-(IBAction)sendInvites:(id)sender{
    
    [self dismissFromParentViewController];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"Check out MappMe.",  @"message",
                                   @"It is a fun app to use!", @"notification_text",
                                   nil];
    
    MappMeAppDelegate *appDelegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate facebook] dialog:@"apprequests"
                         andParams:params
                       andDelegate:nil];
}

@end
