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

@synthesize backgroundView = _backgroundView;
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


//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
//    [self layoutForInterfaceOrientation:toInterfaceOrientation];
//}

/*
 * Reposition the Close button whenever we rotate the view
 */
//- (void)layoutForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    CGRect rect = closeButton.frame;
//    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
//        rect.origin = CGPointMake(255, 95);
//    } else {
//        rect.origin = CGPointMake(340, 15);
//    }
//    closeButton.frame = rect;
//}

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

//- (void)presentInParentViewController:(UIViewController *)parentViewController
//{
//    gradientView = [[GradientView alloc] initWithFrame:parentViewController.view.bounds];
//    [parentViewController.view addSubview:gradientView];
//    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    fadeAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
//    fadeAnimation.toValue = [NSNumber numberWithFloat:1.0f];
//    fadeAnimation.duration = 0.1;
//    [gradientView.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
//
//    self.view.frame = parentViewController.view.bounds;
//    [self layoutForInterfaceOrientation:parentViewController.interfaceOrientation];
//    [parentViewController.view addSubview:self.view];
//    [parentViewController addChildViewController:self];
//    
//    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
//    
//    bounceAnimation.duration = 0.4;
//    bounceAnimation.delegate = self;
//    
//    bounceAnimation.values = [NSArray arrayWithObjects:
//                              [NSNumber numberWithFloat:0.7f],
//                              [NSNumber numberWithFloat:1.2f],
//                              [NSNumber numberWithFloat:0.9f],
//                              [NSNumber numberWithFloat:1.0f],
//                              nil];
//    
//    bounceAnimation.keyTimes = [NSArray arrayWithObjects:
//                                [NSNumber numberWithFloat:0.0f],
//                                [NSNumber numberWithFloat:0.334f],
//                                [NSNumber numberWithFloat:0.666f],
//                                [NSNumber numberWithFloat:1.0f],
//                                nil];
//    
//    bounceAnimation.timingFunctions = [NSArray arrayWithObjects:
//                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
//                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
//                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
//                                       nil];
//    
//    [self.view.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
//}


//- (IBAction)close:(id)sender
//{
//    [self dismissFromParentViewController];
//}

//- (void)dismissFromParentViewController
//{
//    [self willMoveToParentViewController:nil];
//    
//    [UIView animateWithDuration:0.4 animations:^
//     {
//         CGRect rect = self.view.bounds;
//         rect.origin.y += rect.size.height;
//         self.view.frame = rect;
//         gradientView.alpha = 0.0f;
//     }
//                     completion:^(BOOL finished)
//     {
//         [self.view removeFromSuperview];
//         [gradientView removeFromSuperview];
//         [self removeFromParentViewController];
//     }];
//}

- (IBAction)showHomeTown:(id)sender
{
    [self.delegate disSelectLocType:tHomeTown];
    [self dismissFromParentViewController];
}

- (IBAction)showCurrentLocation:(id)sender
{
    [self.delegate disSelectLocType:tCurrentLocation];
    [self dismissFromParentViewController];
}

- (IBAction)showCollege:(id)sender
{
    [self.delegate disSelectLocType:tCollege];
    [self dismissFromParentViewController];
}

- (IBAction)showHighSchool:(id)sender
{
    [self.delegate disSelectLocType:tHighSchool];
    [self dismissFromParentViewController];
}

@end
