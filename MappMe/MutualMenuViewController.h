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
- (void)didSelectFriend:(Person*)person;

@end
@interface MutualMenuViewController : UIViewController{
    locTypeEnum selectedLocType;
    SlidingContainer* container;
    //The other person we are trying to find mutual friends with.
    Person* person;
}

@property (retain) id<MutualMenuDelegate> delegate;
@property locTypeEnum selectedLocType;
@property (nonatomic,retain) SlidingContainer* container;
@property (strong) Person* person;
@end


//- (void)didSelectMutualFriends:(Person*)person;