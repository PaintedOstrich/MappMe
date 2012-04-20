//
//  FriendSearchViewController.h
//  MappMe
//
//  Created by Parker Spielman on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import <UIKit/UIKit.h>
#import "OverlayViewController.h"

@class FriendSearchViewController;
@class Person;
@protocol FriendSearchViewControllerDelegate
- (void)didSelectFriend:(Person*)selectedPerson;
@end


@interface FriendSearchViewController : UITableViewController <UISearchBarDelegate, OverlayViewControllerDelegate> {
    id<FriendSearchViewControllerDelegate> searchDelegate;
    IBOutlet UISearchBar* searchBar;
}

@property (retain) id<FriendSearchViewControllerDelegate> searchDelegate;
@end


