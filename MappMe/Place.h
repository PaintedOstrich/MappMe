//
//  CoordPairs.h
//  MappMe
//
//  Created by Parker Spielman on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

/*
 CoordPairs class used so Location Information can be Permanently Stored In Dictionary
 */
@interface Place : NSObject{
    CLLocationCoordinate2D location;
    NSString *placeName;
}

-(id)initPlaceWithName:(NSString *) name;
-(void)addLat:(NSString *)lat andLong:(NSString *)lon;

@property(nonatomic)CLLocationCoordinate2D location;
@property(nonatomic,retain) NSString * placeName;

@end
