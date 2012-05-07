//
//  AbstractModalViewController.m
//  MappMe
//
//  Created by Di Peng on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AbstractModalViewController.h"
#import "GradientView.h"
#import <QuartzCore/QuartzCore.h>

@interface AbstractModalViewController ()
  - (IBAction)close:(id)sender;
@end

@implementation AbstractModalViewController {
    GradientView *gradientView;
}

@synthesize backgroundView = _backgroundView;

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
    self.backgroundView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.backgroundView.layer.borderWidth = 3.0f;
    self.backgroundView.layer.cornerRadius = 10.0f;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    closeButton = nil;
    backgroundView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    CGRect rect = closeButton.frame;
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        rect.origin = CGPointMake(255, 95);
    } else {
        rect.origin = CGPointMake(340, 15);
    }
    closeButton.frame = rect;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self didMoveToParentViewController:self.parentViewController];
}

- (void)presentInParentViewController:(UIViewController *)parentViewController
{
    gradientView = [[GradientView alloc] initWithFrame:parentViewController.view.bounds];
    [parentViewController.view addSubview:gradientView];
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    fadeAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    fadeAnimation.duration = 0.1;
    [gradientView.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
    
    self.view.frame = parentViewController.view.bounds;
    [self layoutForInterfaceOrientation:parentViewController.interfaceOrientation];
    [parentViewController.view addSubview:self.view];
    //must add this second
    [parentViewController addChildViewController:self];
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    bounceAnimation.duration = 0.4;
    bounceAnimation.delegate = self;
    
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.8f],
                              [NSNumber numberWithFloat:1.1f],
                              [NSNumber numberWithFloat:0.9f],
                              [NSNumber numberWithFloat:1.0f],
                              nil];
    
    bounceAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:0.0f],
                                [NSNumber numberWithFloat:0.334f],
                                [NSNumber numberWithFloat:0.666f],
                                [NSNumber numberWithFloat:1.0f],
                                nil];
    
    bounceAnimation.timingFunctions = [NSArray arrayWithObjects:
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       nil];
    
    [self.view.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
}


- (IBAction)close:(id)sender
{
    [self dismissFromParentViewController];
}

- (void)dismissFromParentViewController
{
    [self willMoveToParentViewController:nil];
    
    //sequential animation through blocks
    [UIView animateWithDuration:0.4 animations:^
     {
         CGRect rect = self.view.bounds;
         rect.origin.y += rect.size.height;
         self.view.frame = rect;
         gradientView.alpha = 0.0f;
     }
                     completion:^(BOOL finished)
     {
         [self.view removeFromSuperview];
         ///remove view first hten controller
         [gradientView removeFromSuperview];
         [self removeFromParentViewController];
     }];
}

@end
