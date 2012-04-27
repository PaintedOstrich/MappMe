//
//  ScreenShotController.h
//  MappMe
//
//  Created by Di Peng on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AbstractModalViewController.h"

@interface ScreenShotController : AbstractModalViewController {
    IBOutlet UIImageView *screenShotView;
}
@property (strong, nonatomic) IBOutlet UIImageView *screenShotView;

-(void) updateScreenShot:(UIImage*) screenShot;

@end
