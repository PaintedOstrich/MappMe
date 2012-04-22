//
//  LocTypeMenuController.h
//  MappMe
//
//  Created by Di Peng on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractModalViewController.h"

@protocol LocTypeMenuControllerDelegate
- (void)disSelectLocType:(locTypeEnum)locType;
@end

@interface LocTypeMenuController : AbstractModalViewController {
     locTypeEnum selectedLocType;
}
@property (retain) id<LocTypeMenuControllerDelegate> delegate;
@property locTypeEnum selectedLocType;

@end
