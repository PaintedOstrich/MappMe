//
//  AbstractSlidingController.m
//  MappMe
//
//  Created by Parker Spielman on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SlidingContainer.h"
#import <QuartzCore/QuartzCore.h>
#import "DebugLog.h"

#import "MainMenuViewController.h"
#import "MutualMenuViewController.h"
#import "PersonMenuSlideController.h"
#import "FacebookDataHandler.h"


/*PLEASE NOTE:  the position of the buttonContainer is veryImportant.  It must be as close to the toggle Button, as the screen will only slide down the height of the container
 Container top must be positioned at 260 px offset*/
@interface SlidingContainer (){
    BOOL open;
    id mainViewController;
    UIView *buttonGroup;
    IBOutlet UILabel *mainLabel;
    IBOutlet UILabel *subLabel;
    
    //Controllers to dealloc
    MainMenuViewController *mmvc;
    MutualMenuViewController *muvc;
    PersonMenuSlideController *pmsc;
}
@end

@implementation SlidingContainer


@synthesize buttonContainer;
@synthesize toggleButton;


@synthesize displayHeight;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    displayHeight = buttonContainer.frame.size.height;	
    [self initMainMenuController];
//    [self initPersonViewController:nil];
//    [self initMutualMenuController];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self layoutForInterfaceOrientation:toInterfaceOrientation];
}

/*
 * Reposition the Close button whenever we rotate the view
 * NOTE: You may need to override this method in subclass if the modal view is of a different size
 */
- (void)layoutForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //any additional layout logic
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self didMoveToParentViewController:self.parentViewController];
}
#pragma mark - View Methods
-(IBAction)toggle:(id)sender{
    if (open) {
        [self slideOutController];
    }
    else{
        [self slideInController];
    }
    open = !open;
}
-(void)updateMainLabel:(NSString*)label{
    mainLabel.text = label;
}
-(void)updateSubLabel:(NSString*)label{
    subLabel.text = label;
}
-(void)closeMenu{
    open = FALSE;
    [self slideOutController];
}
-(void)slideInController{
    DebugLog(@"sliding height %i", displayHeight);
//   int openYPos = y+containerHeight
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0,displayHeight);
	self.view.transform = transform;
	[UIView commitAnimations];
    DebugLog(@"new container y : %i", self.view.frame.origin.y);
}
-(void)slideOutController{
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0,0);
	self.view.transform = transform;
	[UIView commitAnimations];
    DebugLog(@"new container y : %i", self.view.frame.origin.y);
}
- (void)presentInParentViewController:(UIViewController *)parentViewController
{   
    mainViewController = parentViewController;
    int height = self.view.frame.size.height;
    int width = self.view.frame.size.width;
    int xOffset = (parentViewController.view.frame.size.width-width)/2;
    int yOffset = 48 - height; 
//    self.view.frame= CGPointMake(xOffset, 0);
    self.view.frame = CGRectMake(xOffset, yOffset, width, height);

    [parentViewController.view addSubview:self.view];
    [parentViewController addChildViewController:self];
}
#pragma mark - Context Methods
-(void)generalChecks{
    [self closeMenu];
}
-(void)transitionCleanup{
    [self generalChecks];
    [buttonGroup removeFromSuperview];
    if(mmvc){
        [mmvc removeFromParentViewController];
        mmvc=nil;
        DebugLog(@"removed mmvc");
    }
    if(muvc){
        [muvc removeFromParentViewController];
        muvc = nil;
        DebugLog(@"removed muvc");
    }
    if(pmsc){
        [pmsc removeFromParentViewController];
        pmsc = nil;
        DebugLog(@"removed pmsc");
    }
}
-(void)showFriendMenu:(Person*)person{
    [self getPersonData:person];
    [self updateMainLabel:person.name];
    [self updateSubLabel:@""];
    [self transitionCleanup];
    [self initPersonViewController:person];
}
-(void)showMainMenu{
    [self transitionCleanup];
    [self updateSubLabel:@"All Friends:"];
    [self initMainMenuController];
}
-(void)showMutualFriendsMenu:(Person*)person{
    [self transitionCleanup];
    [self initMutualMenuController];
    NSArray *chunks = [person.name componentsSeparatedByString: @" "];
    NSString * label = [[NSString alloc] initWithFormat:@"%@ and My Friends:",[chunks objectAtIndex:0]];
    [self updateSubLabel:label];
}
#pragma mark - SubController Methods
-(CGRect)setViewInBottom:(UIView*)view{
    int height = view.frame.size.height;
    int width = view.frame.size.width;
    int xOffset = (buttonContainer.frame.size.width-width)/2;
    int yOffset = buttonContainer.frame.size.height-height;
    return CGRectMake(xOffset, yOffset, width, height);
    //This used because [view setViewToBottomCenter] resizes views causing buttons to be unpressable
}
-(void)initMainMenuController{
    MainMenuViewController *controller = [[MainMenuViewController alloc] initWithNibName:@"MainMenuViewController" bundle:nil];
    controller.delegate = mainViewController;
    controller.container=self;
    displayHeight = controller.view.frame.size.height;
    [self setViewToBottomCenter:controller.view];
    buttonGroup = controller.view;
    [buttonContainer addSubview:buttonGroup];
    mmvc = controller;//So it can be removed
    [self addChildViewController:controller];
}
-(void)initMutualMenuController{
    MutualMenuViewController *controller = [[MutualMenuViewController alloc] initWithNibName:@"MutualMenuViewController" bundle:nil];
//    [self updateMainLabel:person.name];
    controller.delegate = mainViewController;
    controller.container=self;
    displayHeight = controller.view.frame.size.height;
    buttonGroup = controller.view;
    buttonGroup.frame = [self setViewInBottom:buttonGroup];
    muvc = controller;
    [buttonContainer addSubview:buttonGroup];
    [self addChildViewController:controller];
}
-(void)initPersonViewController:(Person*)person{
    PersonMenuSlideController *controller = [[PersonMenuSlideController alloc] initWithNibName:@"PersonMenuSlideController" bundle:nil];
    controller.delegate = mainViewController;
    controller.container=self;
    controller.person = person;
    displayHeight = controller.view.frame.size.height;
    buttonGroup = controller.view;
    pmsc = controller;//so can be removed
    buttonGroup.frame = [self setViewInBottom:buttonGroup];
    [buttonContainer addSubview:buttonGroup];
    [buttonContainer bringSubviewToFront:buttonGroup];
    [self addChildViewController:controller];
}
-(void)setViewToBottomCenter:(UIView*)view{
    int originX = ((float)(buttonContainer.frame.size.width-view.frame.size.width))/2;
    int originY = MAX(buttonContainer.frame.size.height-view.frame.size.height,0);
    view.frame = CGRectMake(originX, originY, view.frame.size.height, view.frame.size.width);
}
#pragma mark - data methods
-(void)getPersonData:(Person*)person{
    if([person.mutualFriends count]<1){
        FacebookDataHandler *fbDataHandler = [FacebookDataHandler sharedInstance];
        [fbDataHandler getMutualFriends:person.uid];
    }
}

//Remove from view Controller
- (void)dismissFromParentViewController
{
    [self willMoveToParentViewController:nil];
    
    [UIView animateWithDuration:0.4 animations:^
     {
         CGRect rect = self.view.bounds;
         rect.origin.y += rect.size.height;
         self.view.frame = rect;
        // gradientView.alpha = 0.0f;
     }
                     completion:^(BOOL finished)
     {
         [self.view removeFromSuperview];
       //  [gradientView removeFromSuperview];
         [self removeFromParentViewController];
     }];
}

@end
