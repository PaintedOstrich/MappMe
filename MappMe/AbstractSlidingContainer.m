//
//  AbstractSlidingController.m
//  MappMe
//
//  Created by Parker Spielman on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AbstractSlidingContainer.h"
#import <QuartzCore/QuartzCore.h>

@interface AbstractSlidingContainer ()

@end

@implementation AbstractSlidingContainer


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
-(void)slideInController:(CGPoint)origin toPoint:(int)endY{
    int x = origin.x;
    int y = origin.y;
    UIBezierPath *movePath = [UIBezierPath bezierPath];
//    CGPoint midPoint= CGPointMake((icon.layer.position.x)*1.1, abs(icon.layer.position.y)*1.1);
//    
//    [movePath moveToPoint:icon.center];
//    //            [movePath moveToPoint:CGPointMake(200, 300)];
//    [movePath addQuadCurveToPoint:endPoint
//                     controlPoint:midPoint];
//    
//    CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//    moveAnim.path = movePath.CGPath;
//    moveAnim.removedOnCompletion = NO;
//    
//    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
//    //Call self when animation finishes
//    animGroup.delegate = self;
//    
//    animGroup.removedOnCompletion = NO;
//    animGroup.animations = [NSArray arrayWithObjects:moveAnim,  nil];
//    animGroup.duration = MAX(1.0-(float)(pinNum+5)/10,0.3);
//    [icon.layer addAnimation:animGroup forKey:@"position"];
//    [icon.layer setPosition:endPoint];
}
-(void)slideOutController{
    
}
- (void)presentInParentViewController:(UIViewController *)parentViewController
{
    [parentViewController.view addSubview:self.view];
//    CGPoint end = CGPointMake(100, 250);
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
