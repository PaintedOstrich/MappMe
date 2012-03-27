//
//  FriendSearchViewController.h
//  MappMe
//
//  Created by Parker Spielman on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import <UIKit/UIKit.h>
#import "OverlayViewController.h"

@class FriendSearchViewController;

@protocol FriendSearchViewControllerDelegate
- (void)didSelectFriend:(NSString*)uid;
@end


@interface FriendSearchViewController : UITableViewController <UISearchBarDelegate, OverlayViewControllerDelegate> {
    id<FriendSearchViewControllerDelegate> searchDelegate;
    IBOutlet UISearchBar* searchBar;
}

@property (retain) id<FriendSearchViewControllerDelegate> searchDelegate;
@end


