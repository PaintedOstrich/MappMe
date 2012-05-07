//
//  AbstractModalViewController.h
//  MappMe
//
//  Created by Di Peng on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
/*
 * This should be the super class of modal views used in MainViewController.
 * it consists of show/hide animation code. And the logic for close button.
 */

#import <UIKit/UIKit.h>

@interface AbstractModalViewController : UIViewController {
 //The semi transparent background modal view.
 IBOutlet UIView* backgroundView;
 IBOutlet UIButton* closeButton;
}
@property (nonatomic, weak) IBOutlet UIView *backgroundView;

- (void)presentInParentViewController:(UIViewController *)parentViewController;
- (void)dismissFromParentViewController;
@end
