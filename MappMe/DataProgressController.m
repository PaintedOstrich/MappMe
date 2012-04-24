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
    
    //True if current location query is done
    BOOL FBCurLocationDone;
    BOOL FBHomeTownDone;
    BOOL FBEducationDone;
    //True only when location look up queue is empty.
    BOOL AllPlaceQueryDone;
    
    
    //Only update the progress bar if this limit is reached to prevent blocking UI
    int _minUpdateLimit;
    int _updateCount;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        FBCurLocationDone=FALSE;
        FBHomeTownDone=FALSE;
        FBEducationDone=FALSE;
        AllPlaceQueryDone=FALSE;
        _minUpdateLimit = 20;
        _updateCount = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Additional styling of the UI
    [self styleUI];
    [progressbar setProgress:0.0 animated:NO];
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

-(void) queryFinished:(ProgressType)type
{
    if (type == FBCurLocation) {
        FBCurLocationDone = TRUE;
        [self performSelectorOnMainThread:@selector(update:) withObject:nil waitUntilDone:NO];
    } else if (type == FBHomeTown) {
        FBHomeTownDone = TRUE;
        [self performSelectorOnMainThread:@selector(update:) withObject:nil waitUntilDone:NO];
    } else if (type == FBEducation) {
        FBEducationDone = TRUE;
        [self performSelectorOnMainThread:@selector(update:) withObject:nil waitUntilDone:NO];
    } else if (type == PlaceQuery) {
        _updateCount ++;
        if (_updateCount >= _minUpdateLimit) {
            _updateCount = 0;
            [self performSelectorOnMainThread:@selector(update:) withObject:nil waitUntilDone:NO];
        }
    }
}

//update should only be invoked on main thread as it involves UI manipulation.
-(void) update:(NSDecimalNumber*)percentage
{
    float score = 0.0;
    if (FBCurLocationDone) {
        score += 0.2;
    } 
    if (FBHomeTownDone) {
        score += 0.2;
    } 
    if (FBEducationDone) {
        score += 0.2;
    }
    
    score += currentQueuelength/maxLength;
    
    
    [progressbar setProgress:[percentage floatValue] animated:YES];
}

-(void) loadingFinish
{
    [self dismissFromParentViewController];
}

@end
