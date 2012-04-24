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
    float _totalSum;
    float _currentSum;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _totalSum = 0.0;
        _currentSum = 0.0;
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
    
    [UIView animateWithDuration:0.8 animations:^
     {
         CGRect rect = self.view.bounds;
         rect.origin.y -= rect.size.height;
         self.view.frame = rect;
     }
                     completion:^(BOOL finished)
     {
         [self.view removeFromSuperview];
         [self removeFromParentViewController];
     }];
}

-(void) startWithSum:(float)sum{
    _totalSum = sum;
    _currentSum = 0;
    [progressbar setProgress:0.0 animated:NO];
}

-(void) increment:(float)amount
{
    _currentSum += amount;
    float percentage = _currentSum/_totalSum;
    NSDecimalNumber *num = [[NSDecimalNumber alloc] initWithFloat:percentage];
    [self performSelectorOnMainThread:@selector(update:) withObject:num waitUntilDone:NO];
    if (_currentSum >= _totalSum) {
        [self performSelectorOnMainThread:@selector(loadingFinish) withObject:nil waitUntilDone:NO];
    }
}

-(void) update:(NSDecimalNumber*)percentage
{
  [progressbar setProgress:[percentage floatValue] animated:YES];
}

-(void) loadingFinish
{
    [self dismissFromParentViewController];
}

@end
