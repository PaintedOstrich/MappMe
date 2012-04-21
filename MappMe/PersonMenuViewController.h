//
//  PersonMenuViewController.h
//  MappMe
//
//  Created by Parker Spielman on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@protocol MappFriendDelegate
- (void)didSelectFriend:(Person*)person;
@end

@interface PersonMenuViewController : UIViewController{
    Person* person;
    IBOutlet UIButton*mappPersonButton;
    IBOutlet UIButton*mutualFriendButton;
    IBOutlet UIButton*contactButton;
    IBOutlet UIButton*profileButton;
    IBOutlet UIImageView*profileImage;
    IBOutlet UILabel*friendName;
    id<MappFriendDelegate> searchDelegate;
}

@property (retain) id<MappFriendDelegate> searchDelegate;


-(IBAction)showFriend:(id)sender;

@property(nonatomic,retain)Person* person;
@end
