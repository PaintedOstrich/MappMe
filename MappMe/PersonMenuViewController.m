//
//  PersonMenuViewController.m
//  MappMe
//
//  Created by Parker Spielman on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PersonMenuViewController.h"
#import "WebViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MainViewController.h"
#import "Person.h"
#import "FacebookDataHandler.h"
#import "DebugLog.h"

@interface PersonMenuViewController ()
@end

@implementation PersonMenuViewController{
    NSArray*mutualFriends;
    UIViewController*rootVC;
    IBOutlet UIButton*mappPersonButton;
    IBOutlet UIButton*mutualFriendButton;
    IBOutlet UIButton*contactButton;
    IBOutlet UIButton*profileButton;
    IBOutlet UIImageView*profileImage;
    IBOutlet UILabel*friendName;
}

@synthesize person;
@synthesize searchDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)setButtonLabel:(UIButton*)button toLabel:(NSString *)buttonLabel{
    [button setTitle:buttonLabel forState:UIControlStateNormal];
    [button setTitle:buttonLabel forState:UIControlStateHighlighted];
    [button setTitle:buttonLabel forState:UIControlStateDisabled];
    [button setTitle:buttonLabel forState:UIControlStateSelected];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpDelegate];
    [self getPersonData];
   	mutualFriends =[[NSArray alloc] init];
    [self refreshUI];
}

-(void) setUpDelegate
{
    //isMemberOfClass: will only return YES if the instance's class is exactly the same
    //isKindOfClass: will return YES if the instance's class is the same, or a subclass of the given class.
    NSArray *viewControllers = self.navigationController.viewControllers;
    rootVC= [viewControllers objectAtIndex:1];
    if([rootVC isMemberOfClass:[MainViewController class]]){
        [self setSearchDelegate:(id)rootVC];
    } else {
        [NSException raise:@"Invalid controller as delegate for PersonMenuViewController" format:@"The given controller is not MainViewController"];
    }
}

-(void) refreshUI
{
    friendName.text= person.name;
    //profileImage.contentMode = UIViewContentModeScaleAspectFill;
    [profileImage setImageWithURL:[NSURL URLWithString:person.largeProfileUrl] placeholderImage:[UIImage imageNamed:@"profile.png"]];
    NSString * label = [[NSString alloc]initWithFormat:@"Mapp %@",person.name];
    [self setButtonLabel:mappPersonButton toLabel:label];
    label = [[NSString alloc]initWithFormat:@"Mapp Mutual Friends (%i)",[person.mutualFriends count]];
    [self setButtonLabel:mutualFriendButton toLabel:label];
    label = [[NSString alloc]initWithFormat:@"Contact %@",person.name];
    [self setButtonLabel:contactButton toLabel:label];
    label = [[NSString alloc]initWithFormat:@"Go to %@'s Profile",person.name];
    [self setButtonLabel:profileButton toLabel:label];
}
-(void)getPersonData{
    if([self.person.mutualFriends count]<1){
        FacebookDataHandler *fbDataHandler = [FacebookDataHandler sharedInstance];
        [fbDataHandler getMutualFriends:person.uid];
    }
}

-(IBAction)showFriend:(id)sender{
    [searchDelegate didSelectFriend:person];
}
-(IBAction)showMutualFriends:(id)sender{
    DebugLog(@"friend %@", person);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [[self navigationController] setNavigationBarHidden:FALSE animated:TRUE]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
#pragma mark - View Methods

-(void)showProfileView{
    // [self performSegueWithIdentifier:@"showwebview" sender:[annotation.peopleArr objectAtIndex:0]];
}
#pragma mark - Transition Logic
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showwebview"]){
        NSString *fId = [(Person*)sender uid];
		NSString *urlStr = [[NSString alloc] initWithFormat:@"%@%@",@"http://m.facebook.com/profile.php?id=",fId];
		NSURL *url =[[NSURL alloc] initWithString:urlStr];
        WebViewController *controller = segue.destinationViewController;
        controller.url = url;
    } 
} 
@end
