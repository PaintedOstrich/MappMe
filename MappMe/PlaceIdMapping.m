//
//  ObjectIdMapping.m
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceIdMapping.h"
#import "CoordinateLookupManager.h"
#import "MappMeAppDelegate.h"


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

//Adds coords from Google Maps
//This method currently used for education info
-(void)doCoordLookupAndSet:(NSString*)place_id withDict:(NSDictionary *)loc andTypeString:(NSString *)placeTypeName{
    //Get place name from instance Variable
    MappMeAppDelegate*  delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *placeName = [delegate.placeIdMapping getPlaceFromId:place_id];
    CoordPairs * coords = [CoordinateLookupManager manageCoordLookupForEdu:placeName
                                                               withSupInfo:loc andTypeString:placeTypeName];
     [placeAndCoords setObject:coords forKey:place_id];

}
//Adds coords from passed in parameters
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
