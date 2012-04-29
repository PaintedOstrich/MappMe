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

/*PLEASE NOTE:  the position of the buttonContainer is veryImportant.  It must be as close to the toggle Button, as the screen will only slide down the height of the container
 Container top must be positioned at 260 px offset*/
@interface SlidingContainer (){
    BOOL open;
}
@end

@implementation SlidingContainer


@synthesize buttonContainer;
@synthesize toggleButton;


@synthesize containerHeight;
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
	// Do any additional setup after loading the view.
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
//    CGRect rect = closeButton.frame;
//    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
//        rect.origin = CGPointMake(255, 95);
//    } else {
//        rect.origin = CGPointMake(340, 15);
//    }
//    closeButton.frame = rect;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self didMoveToParentViewController:self.parentViewController];
}
-(IBAction)toggle:(id)sender{
    if (open) {
        [self slideOutController];
    }
    else{
        [self slideInController];
    }
    open = !open;
   
}
-(void)slideInController{
    containerHeight = buttonContainer.frame.size.height;
    DebugLog(@"sliding height %i", containerHeight);
//    int openYPos = y+containerHeight
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0,containerHeight);
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
    int height = self.view.frame.size.height;
    int width = self.view.frame.size.width;
    int xOffset = (parentViewController.view.frame.size.width-width)/2;
    int yOffset = 48 - height; 
//    self.view.frame= CGPointMake(xOffset, 0);
    self.view.frame = CGRectMake(xOffset, yOffset, width, height);
    
    //Add Subview first, then this controller to parent controller
    [parentViewController.view addSubview:self.view];
    [parentViewController addChildViewController:self];
//    CGPoint end = CGPointMake(100, 250)
//    [self animatePinDrop:end];
    
}
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
//    
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



- (IBAction)close:(id)sender
{
    [self dismissFromParentViewController];
}

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
