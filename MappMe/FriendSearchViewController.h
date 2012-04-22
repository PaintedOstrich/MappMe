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

@interface FriendSearchViewController : UITableViewController <UISearchBarDelegate, OverlayViewControllerDelegate> {
    IBOutlet UISearchBar* searchBar;
}
@end


