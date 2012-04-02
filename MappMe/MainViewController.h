//
//  MainViewController.h
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MBProgressHUD.h"
#import "FriendSearchViewController.h"

/*Main Controller Interface*/

@protocol ProgressUpdaterDelegate
- (void)updateProgressBar:(float)progressAmount;
@end

@interface MainViewController : UIViewController <MKMapViewDelegate, MBProgressHUDDelegate, FriendSearchViewControllerDelegate> {
    id<ProgressUpdaterDelegate> progressUpdaterDelegate;
    IBOutlet MKMapView* mapView;
    IBOutlet UIButton* locationTypeBtn;
}

@property (retain) id<ProgressUpdaterDelegate> progressUpdaterDelegate;

@end



