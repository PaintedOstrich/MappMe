//
//  ObjectIdMapping.h
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoordPairs.h"


@interface PlaceIdMapping : NSObject{

}

-(void)addId:(NSString *)placeId andPlace:(NSString *)placeName;
-(NSString *)getPlaceFromId:(NSString *)placeId;
-(NSString *)getIdFromPlace:(NSString *)placeName;
-(void)addCoordsLat:(NSString *)lat andLong:(NSString *)lon forPlaceId:(NSString *)placeId;
-(CoordPairs *)getCoordFromId:(NSString *)placeId;


/*  Debug */
-(NSUInteger)getNumPlaces;
@end
