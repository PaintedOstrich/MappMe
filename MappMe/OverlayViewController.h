//
//  OverlayViewController.h
//  MappMe
//
//  Created by #BAL on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OverlayViewController;

@protocol OverlayViewControllerDelegate <NSObject>

- (void)overlayTouched:(OverlayViewController*) overlayController;

@end

@interface OverlayViewController : UIViewController

@property (nonatomic, weak) id <OverlayViewControllerDelegate> delegate;

@end
