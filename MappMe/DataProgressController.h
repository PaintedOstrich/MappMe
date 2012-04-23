//
//  DataProgressController.h
//  MappMe
//
//  Created by Di Peng on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataProgressController : UIViewController

- (void)presentInParentViewController:(UIViewController *)parentViewController;
- (void)dismissFromParentViewController;

//Reset progress bar and current amount to zero and set the total range of progress bar.
- (void) startWithSum:(float)sum;

//Increment by x-amount. Will dismiss itself when the value exceeds sum.
-(void) increment:(float)amount;
@end
