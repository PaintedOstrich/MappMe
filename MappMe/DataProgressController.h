//
//  DataProgressController.h
//  MappMe
//
//  Created by Di Peng on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//The type of query completed.
//Internally, we can tweak the weight of each type of 
//query completion.
typedef enum ProgressType {
  FBCurLocation,
  FBHomeTown,
  FBEducation,
  PlaceQuery
} ProgressType;

@interface DataProgressController : UIViewController

- (void)presentInParentViewController:(UIViewController *)parentViewController;
- (void)dismissFromParentViewController;

-(void) queryFinished:(ProgressType)type;
@end
