//
//  ViewController.h
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface LoginViewController : UIViewController
<FBSessionDelegate>{
    NSArray *permissions;

}

@property (nonatomic, retain) NSArray *permissions;

-(IBAction)loginButtonPress;

@end
