//
//  LocTypeMenuController.h
//  MappMe
//
//  Created by Di Peng on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocTypeMenuController : UIViewController {
     IBOutlet UIView* backgroundView;
}

@property (nonatomic, weak) IBOutlet UIView *backgroundView;

- (void)presentInParentViewController:(UIViewController *)parentViewController;
- (void)dismissFromParentViewController;
@end
