//
//  MainMenuViewController.h
//  MappMe
//
//  Created by Parker Spielman on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlidingContainer.h"

@protocol MainMenuDelegate
- (void)didSelectLocType:(locTypeEnum)locType;
@end
@interface MainMenuViewController : UIViewController{
    locTypeEnum selectedLocType;
    SlidingContainer *container;
}

@property (retain) id<MainMenuDelegate> delegate;
@property locTypeEnum selectedLocType;
@property (nonatomic,retain) SlidingContainer * container;

@end
