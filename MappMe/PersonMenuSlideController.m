//
//  PersonMenuSlideController.m
//  MappMe
//
//  Created by Parker Spielman on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PersonMenuSlideController.h"
#import "SBJSON.h"
#import "MappMeAppDelegate.h"

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
-(void) setBtnTitleForAllStates:(UIButton*)btn withText:(NSString*)txt 
{
    [btn setTitle:txt forState:UIControlStateNormal];
    [btn setTitle:txt forState:UIControlStateHighlighted];
    [btn setTitle:txt forState:UIControlStateDisabled];
    [btn setTitle:txt forState:UIControlStateSelected];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *chunks = [self.person.name componentsSeparatedByString: @" "];
    NSString*mapp =  [[NSString alloc] initWithFormat:@"Mapp %@",[chunks objectAtIndex:0]];
    [self setBtnTitleForAllStates:b1 withText:mapp];
//    if ([person.mutualFriends count] >0) {
//        NSString *subl = [[NSString alloc] initWithFormat:@"Mutual Friends (%i)",[person.mutualFriends count]];
//        [self setBtnTitleForAllStates:b2 withText:subl];
//    }else{
//        [self setBtnTitleForAllStates:b2 withText: @"Mutual Friends"];
//    }
//    [self.view bringSubviewToFront:b6];
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
-(IBAction)sendInvite:(id)sender{
    
    [self.container closeMenu];
    
//    SBJSON *jsonWriter = [SBJSON new];
//    NSDictionary *gift = [NSDictionary dictionaryWithObjectsAndKeys:
//                          @"5", @"social_karma",
//                          @"1", @"badge_of_awesomeness",
//                          nil];
    
   // NSString *giftStr = [jsonWriter stringWithObject:gift];
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"Check out MappMe.",  @"message",
                                   @"It is a fun app to use!", @"notification_text",
                                   person.uid, @"to",
                                   nil];
    
    MappMeAppDelegate *appDelegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate facebook] dialog:@"apprequests"
                         andParams:params
                       andDelegate:nil];
}
-(IBAction)postOnWall:(id)sender{
    
    [self.container closeMenu];
    //SBJSON *jsonWriter = [SBJSON new];
    
//    NSArray* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                      @"Get Started",@"name",@"http://m.facebook.com/apps/hackbookios/",@"link", nil], nil];
//    NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
    // The "to" parameter targets the post to a friend
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   person.uid, @"to",
                                   // @"I'm using the Hackbook for iOS app", @"name",
                                   @"Message posted via MappMe App.", @"caption",
                                   //@"Message Posted via MappMe.", @"description",
                                    @"http://paintedostrichstudio.appspot.com", @"link",
                                   @"http://paintedostrichstudio.appspot.com/resources/img/icon.png", @"picture",
                                   //actionLinksStr, @"actions",
                                   nil];
    
    MappMeAppDelegate *appDelegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate facebook] dialog:@"feed"
                      andParams:params
                    andDelegate:nil];
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
