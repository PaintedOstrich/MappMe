//
//  ScreenShotController.h
//  MappMe
//
//  Created by Di Peng on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AbstractModalViewController.h"
#import "FBRequest.h"

@class Person;
@interface ScreenShotController : AbstractModalViewController <FBRequestDelegate> {
    IBOutlet UIImageView *screenShotView;
    Person* selectedFriend;
}
@property (strong, nonatomic) IBOutlet UIImageView *screenShotView;
@property (strong, retain) Person* selectedFriend;

-(void) updateScreenShot:(UIImage*) screenShot;

@end
