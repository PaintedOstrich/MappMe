//
//  LocTypeMenuController.m
//  MappMe
//
//  Created by Di Peng on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocTypeMenuController.h"
#import <QuartzCore/QuartzCore.h>
#import "GradientView.h"

@interface LocTypeMenuController () {
    IBOutlet UIButton* hometownBtn;
    IBOutlet UIButton* currentLocationBtn;
    IBOutlet UIButton* collegeBtn;
    IBOutlet UIButton* highschoolBtn;
}

@end

@implementation LocTypeMenuController{
}

@synthesize delegate = _delegate;
@synthesize selectedLocType=_selectedLocType;

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
    [self updateButtonHighlight];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self didMoveToParentViewController:self.parentViewController];
}

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
//    [self.delegate didSelectLocType:tHomeTown];
    [self dismissFromParentViewController];
}

- (IBAction)showCurrentLocation:(id)sender
{
//    [self.delegate didSelectLocType:tCurrentLocation];
    [self dismissFromParentViewController];
}

- (IBAction)showCollege:(id)sender
{
//    [self.delegate didSelectLocType:tCollege];
    [self dismissFromParentViewController];
}

- (IBAction)showHighSchool:(id)sender
{
//    [self.delegate didSelectLocType:tHighSchool];
    [self dismissFromParentViewController];
}

@end
