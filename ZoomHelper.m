//
//  ZoomHelper.m
//  ArrestsPlotter
//
//  Created by #BAL on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZoomHelper.h"
#import "MyAnnotation.h"

@implementation ZoomHelper

+(void) zoomToFitAnnoations:(MKMapView*)mapView {
    if([mapView.annotations count] == 0) {
        [self zoomToWorld:mapView];
        return;
    }
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(MyAnnotation* annotation in mapView.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.2; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.2; // Add a little extra space on the sides
    
    float minBoxSize = 10;
    region.span.latitudeDelta = fmax(minBoxSize,  region.span.latitudeDelta);
    region.span.longitudeDelta = fmax(minBoxSize, region.span.longitudeDelta);
    
    //NSLog(@"BEFORE region.center.longitude: %f", region.center.longitude);
    if (region.span.longitudeDelta > 60) {
        //Try to shift the map towards USA
        float USAEastLongitude = -75.5;
        if (region.center.longitude > USAEastLongitude) {
          region.center.longitude = region.center.longitude - 30;   
        }
    }
    
    //NSLog(@"latitudeDelta: %f, Longgi Delta: %f, region.center.longitude: %f", region.span.latitudeDelta, region.span.longitudeDelta, region.center.longitude);
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}

//Zoom out all the way to world map view.
+(void) zoomToWorld: (MKMapView*)mapView {
  MKCoordinateRegion region = MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(180, 360));
  [mapView setRegion:region animated:YES]; 
}

@end
