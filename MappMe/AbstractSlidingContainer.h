//
//  AbstractSlidingController.h
//  MappMe
//
//  Created by Parker Spielman on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AbstractSlidingContainer : UIViewController{
// 
    //IBOutlet UIView* backgroundView;
//    IBOutlet UIView* toggleButton;
    int containerHeight;
}

@property (nonatomic, weak) IBOutlet UIView *backgroundView;
@property (nonatomic, weak) IBOutlet UIView *toggleButton;

- (void)presentInParentViewController:(UIViewController *)parentViewController;
- (void)dismissFromParentViewController;
@end
