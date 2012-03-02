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

@interface MainViewController : UIViewController <MKMapViewDelegate, MBProgressHUDDelegate> {
    IBOutlet MKMapView* mapView;
}

@property(nonatomic,retain)	IBOutlet MKMapView* mapView;

-(IBAction)logoutBtnTapped;

@end
