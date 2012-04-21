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

@interface PersonMenuViewController ()
@end

@implementation PersonMenuViewController{
    NSArray*mutualFriends;
    UIViewController*rootVC;
    
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
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    rootVC= [viewControllers objectAtIndex:0];
    [self setSearchDelegate:(id)rootVC];
	mutualFriends =[[NSArray alloc] init];
    friendName.text= person.name;
    profileImage.contentMode = UIViewContentModeScaleAspectFill;
    [profileImage setImageWithURL:[NSURL URLWithString:person.largeProfileUrl] placeholderImage:[UIImage imageNamed:@"profile.png"]];
    NSString * label = [[NSString alloc]initWithFormat:@"Mapp %@",person.name];
    [self setButtonLabel:mappPersonButton toLabel:label];
    label = [[NSString alloc]initWithFormat:@"Mapp Mutual Friends (%i)",[mutualFriends count]];
    [self setButtonLabel:mutualFriendButton toLabel:label];
    label = [[NSString alloc]initWithFormat:@"Contact %@",person.name];
    [self setButtonLabel:contactButton toLabel:label];
    label = [[NSString alloc]initWithFormat:@"Go to %@'s Profile",person.name];
    [self setButtonLabel:profileButton toLabel:label];
}
-(IBAction)showFriend:(id)sender{
    //FIXME: Will need to change controller when merging
//    UIViewController *mvc = ;
//    while (![mvc isKindOfClass:[MainViewController class]]) {
//        NSLog(@"trying to match controllers");
//        mvc= mvc.presentingViewController;
//    }
//    
//    [[self navigationController] popViewControllerAnimated:YES];
    [searchDelegate didSelectFriend:self.person];
    [[self navigationController] popToViewController:rootVC animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
