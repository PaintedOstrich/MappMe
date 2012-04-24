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
#import "PersonMenuViewController.h"
#import "LocTypeMenuController.h"
#import "CoordinateLookupManager.h"

/*Main Controller Interface*/

@interface MainViewController : UIViewController <MKMapViewDelegate, MBProgressHUDDelegate, LocTypeMenuControllerDelegate, MappFriendDelegate, CoordinateLookupManagerDelegate> {
    IBOutlet MKMapView* _mapView;
}
@end



