//
//  LocTypeMenuController.h
//  MappMe
//
//  Created by Di Peng on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocTypeMenuControllerDelegate
- (void)disSelectLocType:(locTypeEnum)locType;
@end

@interface LocTypeMenuController : UIViewController {
     IBOutlet UIView* backgroundView;
}

@property (nonatomic, weak) IBOutlet UIView *backgroundView;
@property (retain) id<LocTypeMenuControllerDelegate> delegate;

- (void)presentInParentViewController:(UIViewController *)parentViewController;
- (void)dismissFromParentViewController;
@end
