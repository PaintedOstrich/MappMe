//
//  ViewController.m
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "MappMeAppDelegate.h"
#import "DebugLog.h"
#import <QuartzCore/QuartzCore.h>
#import "DebugLog.h"
#import "Timer.h"

//#define MAX(a,b) ((a < b) ?  (b) : (a))

@implementation LoginViewController{
    MappMeAppDelegate *delegate;
    UIView *buttonContainer;
    UIImageView *icon1,*icon2,*icon3,*icon4,*icon5;
    NSMutableArray *animationQueue;
    int pinNum;
    UIButton *loginButton;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)loginButtonPress{
    NSArray* permissions = [[NSArray alloc] initWithObjects:@"friends_hometown",@"friends_location",@"friends_work_history",@"friends_education_history", nil];
    [[delegate facebook] authorize:permissions];
}
#pragma mark - Animation Methods
-(void)fadeInLogin{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.4];
    [loginButton setAlpha:1.0];
    [UIView commitAnimations];

}
-(void)animatePinDrop:(UIImageView*)icon toEndPoint:(CGPoint)endPoint{
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    CGPoint midPoint= CGPointMake((icon.layer.position.x)*1.1, abs(icon.layer.position.y)*1.1);
    
    [movePath moveToPoint:icon.center];
    //            [movePath moveToPoint:CGPointMake(200, 300)];
    [movePath addQuadCurveToPoint:endPoint
                     controlPoint:midPoint];
    
    CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnim.path = movePath.CGPath;
    moveAnim.removedOnCompletion = NO;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    //Call self when animation finishes
    animGroup.delegate = self;
    
    animGroup.removedOnCompletion = NO;
    animGroup.animations = [NSArray arrayWithObjects:moveAnim,  nil];
    animGroup.duration = MAX(1.0-(float)(pinNum+5)/10,0.3);
    [icon.layer addAnimation:animGroup forKey:@"position"];
    [icon.layer setPosition:endPoint];
}
- (void)startAnimation{

    [self animationDidStop:nil finished:YES];
    
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        //End of animation queue
        if (pinNum<5) {
            switch (pinNum++) {
                case 0:
                {
                    CGPoint endPoint= CGPointMake(132, 155);
                    [self animatePinDrop:icon1 toEndPoint:endPoint];
                    break;
                }
                case 1:
                {
                    CGPoint endPoint= CGPointMake(205, 120);
                    [self animatePinDrop:icon2 toEndPoint:endPoint];
                    break;
                }
                case 2:
                {
                    CGPoint endPoint= CGPointMake(104, 110);
                    [self animatePinDrop:icon3 toEndPoint:endPoint];
                    break;
                }
                case 3:
                {
                    CGPoint endPoint= CGPointMake(238, 150);
                    [self animatePinDrop:icon4 toEndPoint:endPoint];
                    break;
                }
                case 4:
                {
                    CGPoint endPoint= CGPointMake(177, 145);
                    [self animatePinDrop:icon5 toEndPoint:endPoint];
                    break;
                }
                    
                default:
                    break;
            }
        }
        else{
            [self fadeInLogin];
        }
    }
}
/*MORE ANIMATION METHODS */
//            CABasicAnimation *rotationAnimation; rotationAnimation = [CABasicAnimation animationWithKeyPath:@”transform.rotation.z”]; rotationAnimation.toValue = [NSNumber numberWithFloat:angleRadians]; rotationAnimation.duration = 0.3; rotationAnimation.cumulative = YES; self.layer.actions = [NSDictionary dictionaryWithObject:rotationAnimation forKey:@”rotationAnimation”];

//			CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
//			scaleAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
//			scaleAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
//			scaleAnim.removedOnCompletion = YES;
//			
//			CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"alpha"];
//			opacityAnim.fromValue = [NSNumber numberWithFloat:1.0];
//			opacityAnim.toValue = [NSNumber numberWithFloat:1.0];
//			opacityAnim.removedOnCompletion = YES;

#pragma mark - View lifecycle
    
    
- (void)viewDidLoad
{
    [super viewDidLoad];
    animationQueue = [[NSMutableArray alloc] initWithCapacity:5];
    pinNum = 0;
    delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];

	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    buttonContainer = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:buttonContainer];
    
    icon1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"welcomePin.png"]];
    icon1.center = CGPointMake(80, -60);
    [buttonContainer addSubview:icon1];
    
    icon2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"welcomePin.png"]];
    icon2.center = CGPointMake(200, -60);
    [buttonContainer addSubview:icon2];
    
    icon3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"welcomePin.png"]];
    icon3.center = CGPointMake(90, -60);
    [buttonContainer addSubview:icon3];
    
    icon4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"welcomePin.png"]];
    icon4.center = CGPointMake(150, -60);
    [buttonContainer addSubview:icon4];
    
    icon5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"welcomePin.png"]];
    icon5.center = CGPointMake(100, -60);
    [buttonContainer addSubview:icon5];
    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    button.center = CGPointMake(40, 200);
//    [button setTitle:@"Animate" forState:UIControlStateNormal];
//    [button sizeToFit];
//    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [buttonContainer addSubview:button];
    
    // Login Button
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat xLoginButtonOffset = self.view.center.x - (240/2);
    CGFloat yLoginButtonOffset = self.view.bounds.size.height - (45 + 18);
    loginButton.frame = CGRectMake(xLoginButtonOffset,yLoginButtonOffset,240,45);
    [loginButton addTarget:self
                    action:@selector(loginButtonPress)
          forControlEvents:UIControlEventTouchUpInside];
    UIImage *loginImage = [UIImage imageNamed:@"LoginWithFacebookNormal@2x.png"];
    UIImage *stretchableButtonImage = [loginImage stretchableImageWithLeftCapWidth:0 topCapHeight:0]; 
    [loginButton setBackgroundImage:stretchableButtonImage forState:UIControlStateNormal];
    UIImage *loginImagePressed = [UIImage imageNamed:@"LoginWithFacebookPressed@2x.png"];
    UIImage *stretchableButtonImagePress = [loginImagePressed stretchableImageWithLeftCapWidth:0 topCapHeight:0]; 
    [loginButton setBackgroundImage:stretchableButtonImagePress forState:UIControlStateHighlighted];
    [loginButton setAlpha:0.0];
    
    [self.view addSubview:loginButton];

}

- (void)viewDidUnload
{
    [super viewDidUnload];

}

- (void)viewWillAppear:(BOOL)animated
{
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    sleep(0.7);
    [self startAnimation];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - FB Private Helpers
- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

#pragma mark - FBSessionDelegate Methods
/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
    NSLog(@"called fbDidLogin");
    [self storeAuthData:[delegate.facebook accessToken] expiresAt:[delegate.facebook expirationDate]];
    
    UINavigationController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNavController"];
    delegate.window.rootViewController = controller;
    [delegate.window makeKeyAndVisible];
}
-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSLog(@"token extended");
    [self storeAuthData:accessToken expiresAt:expiresAt];
}
/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"User denied authorization");
    //TODO should show some encouragement words to guide the user along.
}
/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
    // Remove saved authorization information if it exists and it is
    // ok to clear it (logout, session invalid, app unauthorized)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    //    [self showLoggedOut];
    NSLog(@"FBDIDLOGOUT CALLED");
}

/**
 * Called when the session has expired.
 */
- (void)fbSessionInvalidated {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Auth Exception"
                              message:@"Your session has expired."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil,
                              nil];
    [alertView show];
    [self fbDidLogout];
}

@end
