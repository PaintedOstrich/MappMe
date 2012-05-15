//
//  ScreenShotController.h
//  MappMe
//
//  Created by Di Peng on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AbstractModalViewController.h"
#import "FBRequest.h"
#import "FBConnect.h"

@class Person;
@interface ScreenShotController : AbstractModalViewController <FBRequestDelegate, FBSessionDelegate, UITextFieldDelegate> {
    IBOutlet UIImageView *screenShotView;
    Person* selectedFriend;
}
@property (strong, nonatomic) IBOutlet UIImageView *screenShotView;
@property (strong, retain) Person* selectedFriend;

-(void) updateScreenShot:(UIImage*) screenShot;

@end
