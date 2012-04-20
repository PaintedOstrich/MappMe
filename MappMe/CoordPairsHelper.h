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
@interface CoordPairsHelper : NSObject{
    CLLocationCoordinate2D location;
}

-(id)initWithLat:(NSString *)lat andLong:(NSString *)lon;
-(NSString*) latAsString;
-(NSString*) longAsString;
@property(nonatomic)CLLocationCoordinate2D location;

@end