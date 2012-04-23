//
//  DataProgressController.m
//  MappMe
//
//  Created by Di Peng on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataProgressController.h"
#import <QuartzCore/QuartzCore.h>

@interface DataProgressController ()

@end

@implementation DataProgressController {
    IBOutlet UIView* background;
    IBOutlet UIProgressView* progressbar;
    IBOutlet UILabel* locTypeLabel;
}

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
    // Additional styling of the UI
    [self styleUI];
}

-(void) styleUI
{
    //round corners
    CALayer *locTypeLayer = locTypeLabel.layer;
    [locTypeLayer setMasksToBounds:YES];
    [locTypeLayer setCornerRadius:5.0f];
    [locTypeLayer setBorderWidth:2.0f];
    [locTypeLayer setBorderColor: [[UIColor blackColor] CGColor]];
    [locTypeLayer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    
    //Rounded Container Corners
    CALayer *bg = background.layer;
    [bg setMasksToBounds:YES];
    [bg setCornerRadius:8.0f];
    [bg setBorderWidth:2.0f];
    [bg setBorderColor: [[UIColor blackColor] CGColor]];
    [bg setBackgroundColor: [[UIColor blackColor] CGColor]];
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
//
//-(void) layoutForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)presentInParentViewController:(UIViewController *)parentViewController
{

    [parentViewController.view addSubview:self.view];
    [parentViewController addChildViewController:self];
}

- (void)dismissFromParentViewController
{
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}



@end
