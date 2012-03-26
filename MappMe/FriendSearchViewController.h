//
//  FriendSearchViewController.h
//  MappMe
//
//  Created by Parker Spielman on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FriendSearchViewController;

@protocol SearchResultDelegate
- (void)didSelectFriend:(NSString*)uid;
- (void)didCancel;
@end


@interface FriendSearchViewController : UITableViewController <UISearchBarDelegate> {
    id<SearchResultDelegate> searchDelegate;
    IBOutlet UISearchBar* searchBar;
}

@property (retain) id<SearchResultDelegate> searchDelegate;
@end


