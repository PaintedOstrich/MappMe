//
//  ScreenShotController.m
//  MappMe
//
//  Created by Di Peng on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScreenShotController.h"
#import "MappMeAppDelegate.h"

@interface ScreenShotController ()

@end

@implementation ScreenShotController
@synthesize screenShotView;

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
}

- (void)viewDidUnload
{
    [self setScreenShotView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

/*
 * Does nothing so cancel(close button) is not moved
 */
- (void)layoutForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
}

/*
 * Update the image in imageview with the passed in screenShot image
 * The reason for this method is that we need to rotate our imageView -90 degrees
 * as the passed in image is always in portrait mode
 */
static inline double radians (double degrees) {return degrees * M_PI/180;}
-(void) updateScreenShot:(UIImage*) screenShot
{
    [self.screenShotView setImage:[self scaleAndRotateImage:screenShot]];
//    CGAffineTransform rotate = CGAffineTransformMakeRotation(radians(-90.0));
//    [self.screenShotView setTransform:rotate];
}

-(IBAction) uploadImage
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   self.screenShotView.image, @"picture",
                                   nil];
    MappMeAppDelegate *delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[delegate facebook] requestWithGraphPath:@"me/photos"
                                    andParams:params
                                andHttpMethod:@"POST"
                                  andDelegate:self];
}

-(UIImage*)scaleAndRotateImage:(UIImage *)image
{
     int kMaxResolution = 320; // Or whatever
    
     CGImageRef imgRef = image.CGImage;
    
     CGFloat width = CGImageGetWidth(imgRef);
     CGFloat height = CGImageGetHeight(imgRef);
    
     CGAffineTransform transform = CGAffineTransformIdentity;
     CGRect bounds = CGRectMake(0, 0, width, height);
     if (width > kMaxResolution || height > kMaxResolution) {
          CGFloat ratio = width/height;
          if (ratio > 1) {
               bounds.size.width = kMaxResolution;
               bounds.size.height = bounds.size.width / ratio;
              }
          else {
               bounds.size.height = kMaxResolution;
               bounds.size.width = bounds.size.height * ratio;
              }
         }
    
     CGFloat scaleRatio = bounds.size.width / width;
     CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
     CGFloat boundHeight;

     boundHeight = bounds.size.height;
     bounds.size.height = bounds.size.width;
     bounds.size.width = boundHeight;
     transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
     transform = CGAffineTransformRotate(transform, M_PI / 2.0);
    
     UIGraphicsBeginImageContext(bounds.size);
    
     CGContextRef context = UIGraphicsGetCurrentContext();
    

     CGContextScaleCTM(context, -scaleRatio, scaleRatio);
     CGContextTranslateCTM(context, -height, 0);

    
     CGContextConcatCTM(context, transform);
    
     CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
     UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
    
     return imageCopy;
}
@end