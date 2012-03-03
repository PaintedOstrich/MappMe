//
//  ObjectIdMapping.m
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceIdMapping.h"


@implementation PlaceIdMapping{
    NSMutableDictionary *idForPlace;
    NSMutableDictionary *placeForId;
    NSMutableDictionary *placeAndCoords;

}


-(id)init{
    if (self = [super init]) {
        placeForId = [[NSMutableDictionary alloc] init];
        idForPlace = [[NSMutableDictionary alloc] init];
        placeAndCoords = [[NSMutableDictionary alloc] init];

    }
    return self;
}

-(void)addId:(NSString *)placeId andPlace:(NSString *)placeName{
    //If empty
    if([placeForId objectForKey:placeId]== nil) {
        [placeForId setValue:placeName forKey:placeId];
        [idForPlace setValue:placeId forKey:placeName];
    }
}
-(void)addCoordsLat:(NSString *)lat andLong:(NSString *)lon forPlaceId:(NSString *)placeId{
    if([placeAndCoords objectForKey:placeId]== nil) {
        CoordPairs *item = [[CoordPairs alloc] initWithLat:lat andLong:lon];
        [placeAndCoords setObject:item forKey:placeId];
    }
}
-(NSString *)getPlaceFromId:(NSString *)placeId{
    return [placeForId objectForKey:placeId];
}
-(NSString *)getIdFromPlace:(NSString *)placeName{
    return [idForPlace objectForKey:placeName];
}
-(CoordPairs *)getCoordFromId:(NSString *)placeId{
    return [placeAndCoords objectForKey:placeId];
}

#pragma mark - Debug
-(NSUInteger)getNumPlaces{
    return [idForPlace count];
}
                      
@end
