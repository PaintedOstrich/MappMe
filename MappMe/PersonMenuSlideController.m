//
//  PersonMenuSlideController.m
//  MappMe
//
//  Created by Parker Spielman on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PersonMenuSlideController.h"

@interface PersonMenuSlideController ()

@end

@implementation PersonMenuSlideController{
    IBOutlet UIButton *b1,*b2,*b3,*b4,*b5,*b6;
}

@synthesize delegate;
@synthesize container;
@synthesize person;
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
    [self.view bringSubviewToFront:b6];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - Facebook Method Calls
-(IBAction)goToProfile:(id)sender{
    
    [self.container closeMenu];
}
-(IBAction)sendMessage:(id)sender{
    
    [self.container closeMenu];
}
-(IBAction)postOnWall:(id)sender{
    
    [self.container closeMenu];
}
#pragma mark - Map Method Calls
-(IBAction)mappSelf:(id)sender{
    [self.delegate didSelectFriend:self.person];
    [self.container closeMenu];
}
-(IBAction)selMutualFriends:(id)sender{
    [self.delegate didSelectMutualFriends:self.person];
    [self.container showMutualFriendsMenu:person];
}
- (IBAction)backToFriends:(id)sender
{
    [self.container showMainMenu];
    [self.delegate backToFriends];
}

@end
