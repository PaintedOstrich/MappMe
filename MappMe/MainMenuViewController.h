//
//  MainMenuViewController.h
//  MappMe
//
//  Created by Parker Spielman on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MainMenuDelegate
- (void)didSelectLocType:(locTypeEnum)locType;
@end
@interface MainMenuViewController : UIViewController{
    locTypeEnum selectedLocType;
}

@property (retain) id<MainMenuDelegate> delegate;
@property locTypeEnum selectedLocType;

@end
