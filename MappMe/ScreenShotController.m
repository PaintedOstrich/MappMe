//
//  ScreenShotController.m
//  MappMe
//
//  Created by Di Peng on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScreenShotController.h"
#import "MappMeAppDelegate.h"
#import "MBProgressHUD.h"
#import "Person.h"

@interface ScreenShotController ()

@end

@implementation ScreenShotController {
    //Uploading HUD
    MBProgressHUD* HUD;
    MappMeAppDelegate *appDelegate;
    IBOutlet UITextField* textfield;
}
@synthesize screenShotView, selectedFriend;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        selectedFriend = nil;
        appDelegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [textfield setDelegate:self];
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
-(void) updateScreenShot:(UIImage*) screenShot
{
    [self.screenShotView setImage:[self rotateImage:screenShot]];
}

-(IBAction) uploadImage
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   self.screenShotView.image, @"picture",
                                   nil];
    
    //Add image description if user has added anything.
    if ([textfield.text length] > 0) {
        [params setValue:textfield.text forKey:@"caption"];
    }
    
    
    [[appDelegate facebook] requestWithGraphPath:@"me/photos"
                                    andParams:params
                                andHttpMethod:@"POST"
                                  andDelegate:self];
}

// This rotate image method is not generic. But it works for us
//It will rotate the image into right position for uploading to 
//facebook
-(UIImage*)rotateImage:(UIImage *)image
{
   //  int kMaxResolution = 320; // Or whatever
    
     CGImageRef imgRef = image.CGImage;
    
     CGFloat width = CGImageGetWidth(imgRef);
     CGFloat height = CGImageGetHeight(imgRef);
    
     CGAffineTransform transform = CGAffineTransformIdentity;
     CGRect bounds = CGRectMake(0, 0, width, height);
    
     CGFloat scaleRatio = bounds.size.width / width;
     CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
     CGFloat boundHeight;
    
    boundHeight = bounds.size.height;  
    bounds.size.height = bounds.size.width;  
    bounds.size.width = boundHeight;  
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft) {
        transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
        transform = CGAffineTransformRotate(transform, M_PI / 2.0);   
    } else  {
        transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);  
        transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
    }
    
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

#pragma mark - facebook request delegate methods

- (void)requestLoading:(FBRequest *)request
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	HUD.labelText = @"Uploading...";
	[HUD show:YES];
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    DebugLog(@"didReceiveResponse:%@", [response description]);
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    DebugLog(@"didFailWithError:%@", [error localizedDescription]);
    [HUD hide:YES];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Oooops!"
                          message: @"I could not upload the image. Please make sure you are online and try again!"
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    //DebugLog(@"didLoad:%@", [result description]);
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    
	// Set custom view mode
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = @"Upload Success";
    
    // Delay execution of my block for 1 seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
       [HUD hide:YES];
       [self dismissFromParentViewController];
    });
    
    [self tagFriend:(NSDictionary*)result];
}

//Try to tag friend in uploaded photo if selectedFriend is not nil
//We do not specify delegate so tagging will fail silently.
- (void) tagFriend:(NSDictionary*)result
{
    if (selectedFriend != nil ) {
        NSString *photoID = [NSString stringWithFormat:@"%@", [result valueForKey:@"id"]];
        DebugLog(@"trying to tag friend!!! %@", selectedFriend.name);
        [[appDelegate facebook] requestWithGraphPath:[NSString stringWithFormat:@"%@/tags/%@?access_token=%@", photoID, selectedFriend.uid, [appDelegate facebook].accessToken]
                                           andParams:nil 
                                       andHttpMethod:@"POST" andDelegate:nil];   
    }
}

#pragma mark -- UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
