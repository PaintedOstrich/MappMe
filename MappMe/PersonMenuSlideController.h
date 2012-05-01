//
//  PersonMenuSlideController.h
//  MappMe
//
//  Created by Parker Spielman on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "SlidingContainer.h"

@protocol PersonMenuDelegate
- (void)didSelectFriend:(Person*)person;
- (void)didSelectMutualFriends:(Person*)person;
- (void)didSelectProfile:(Person*)person;
- (void)didSelectMessage:(Person*)person;
- (void)didSelectWallPost:(Person*)person;
- (void)backToFriends;
@end

@interface PersonMenuSlideController : UIViewController{
    SlidingContainer * container;
    Person* person;
}

@property (retain) id<PersonMenuDelegate> delegate;
@property (nonatomic,retain) SlidingContainer * container;
@property (nonatomic,retain) Person *person;
@end
