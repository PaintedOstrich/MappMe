//
//  ZoomHelper.h
//  ArrestsPlotter
//
//  Created by #BAL on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// This class will help handle zooming in and out of the map view,
// given a array of coordinates. It makes sure that these coordinates are shown
// given the level of zoom.

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ZoomHelper : NSObject {

}

+(void) zoomToFitAnnoations:(MKMapView*)mapView;
+(void) zoomToWorld:(MKMapView*)mapView;

@end
