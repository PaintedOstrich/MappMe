//
//  ObjectIdMapping.h
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Place.h"


@interface PlaceContainer : NSObject{

}
//put annotation methods into this class

-(Place*)get:(NSString*)town_id;
-(Place*)update:(NSString*)town_id withName:(NSString*)town_name;
-(Place*)update:(NSString*)town_id withLat:(NSString*)lat andLong:(NSString*)lon;
-(int)count;




///*Adding (place,id) pair to mapping */
//-(void)addId:(NSString *)placeId andPlaceName:(NSString *)placeName;
//-(void)addCoordsLat:(NSString *)lat andLong:(NSString *)lon forPlaceId:(NSString *)placeId;
//-(void)doCoordLookupAndSet:(NSString*)place_id withDict:(NSDictionary *)loc andTypeString:(NSString *)placeTypeName;
//
///*lookup methods*/
//-(NSString *)getPlaceNameFromId:(NSString *)placeId;
//-(NSString *)getIdFromPlace:(NSString *)placeName;
//-(Place *)getPlaceFromId:(NSString *)placeId;
//
//
///*  Debug */
//-(NSUInteger)getNumPlaces;
@end
