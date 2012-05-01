//
//  MutualMenuViewController.h
//  MappMe
//
//  Created by Parker Spielman on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "SlidingContainer.h"

@protocol MutualMenuDelegate
- (void)didSelectLocType:(locTypeEnum)locType;
- (void)backToAllFriends;

@end
@interface MutualMenuViewController : UIViewController{
    locTypeEnum selectedLocType;
    SlidingContainer* container;
}

@property (retain) id<MutualMenuDelegate> delegate;
@property locTypeEnum selectedLocType;
@property (nonatomic,retain) SlidingContainer* container;
@end


//- (void)didSelectMutualFriends:(Person*)person;