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
#import "DataProgressUpdater.h"

/*Main Controller Interface*/

@interface MainViewController : UIViewController <MKMapViewDelegate, MBProgressHUDDelegate, ProgressUpdaterDelegate, FriendSearchViewControllerDelegate> {
    IBOutlet MKMapView* mapView;
}



@end



