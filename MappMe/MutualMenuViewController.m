//
//  MutualMenuViewController.m
//  MappMe
//
//  Created by Parker Spielman on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MutualMenuViewController.h"
#import "UtilFunctions.h"

@interface MutualMenuViewController (){
    IBOutlet UIButton* hometownBtn;
    IBOutlet UIButton* currentLocationBtn;
    IBOutlet UIButton* collegeBtn;
    IBOutlet UIButton* highschoolBtn;
    IBOutlet UIButton* backToFriend;
    IBOutlet UIButton* backToFriends;
}
@end

@implementation MutualMenuViewController

@synthesize selectedLocType;
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
    NSArray *chunks = [person.name componentsSeparatedByString: @" "];
    NSString*mapp =  [[NSString alloc] initWithFormat:@"Mapp %@",[chunks objectAtIndex:0]];
    [UtilFunctions setBtnTitleForAllStates:backToFriend withText:mapp];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - control logic
-(void)updateButtonHighlight
{
    switch (self.selectedLocType) {
        case tHomeTown:
            hometownBtn.highlighted = TRUE;
            break;
        case tCurrentLocation:
            currentLocationBtn.highlighted = TRUE;
            break;
        case tCollege:
            collegeBtn.highlighted = TRUE;
            break;
        case tHighSchool:
            highschoolBtn.highlighted = TRUE;
            break;
        default:
            break;
    }
}

- (IBAction)showHomeTown:(id)sender
{
    [self.container closeMenu];
    [self.delegate didSelectLocType:tHomeTown];
}

- (IBAction)showCurrentLocation:(id)sender
{
    [self.container closeMenu];
    [self.delegate didSelectLocType:tCurrentLocation];    
}

- (IBAction)showCollege:(id)sender
{
    [self.container closeMenu];
    [self.delegate didSelectLocType:tCollege];
}

- (IBAction)showHighSchool:(id)sender
{
    [self.container closeMenu];
    [self.delegate didSelectLocType:tHighSchool];
}
- (IBAction)backToFriend:(id)sender
{
    [self.container showFriendMenu:person];
    [self.delegate didSelectFriend:person];
}

- (IBAction)backToFriends:(id)sender
{
    [self.container showMainMenu];
    [self.delegate backToFriends];
}

@end
