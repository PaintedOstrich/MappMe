//
//  ObjectIdMapping.m
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceContainer.h"
#import "CoordinateLookupManager.h"
#import "MappMeAppDelegate.h"
#import "DebugLog.h"


@implementation PlaceContainer{
    /*Container has two mappings: id to placeObject, and name to Id.  N
     ame is passed around in instances like mapCallout's, so also necessary*/
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
#pragma mark - retrieving content
/*Returning Place objects: name, id, and coordinates*/
-(Place *)getPlaceFromId:(NSString *)placeId{
    return [placeForId objectForKey:placeId];
}
-(NSString *)getIdFromPlace:(NSString *)placeName{
    return [idForPlace objectForKey:placeName];
}
-(NSString *)getPlaceNameFromId:(NSString *)placeId{
    Place * place = [self getPlaceFromId:placeId];
    return place.placeName;
}

#pragma mark -addding new place and new place location
-(void)addId:(NSString *)placeId andPlaceName:(NSString *)placeName{
    //If empty
    if([placeForId objectForKey:placeId]== nil) {
        Place * location = [[Place alloc] initPlaceWithName:placeName];
        [placeForId setValue:location forKey:placeId];
        [idForPlace setValue:placeId forKey:placeName];
    }
}

//Adds coords from Google Maps
//This method currently used for education info
-(void)doCoordLookupAndSet:(NSString*)place_id withDict:(NSDictionary *)loc andTypeString:(NSString *)placeTypeName{
    //Get place name from instance Variable
    Place *place = [self getPlaceFromId:place_id];
    /*Note: Can Be Nil*/
    CoordPairsHelper *coordpair= [CoordinateLookupManager manageCoordLookupForEdu:place.placeName
                                                               withSupInfo:loc andTypeString:placeTypeName];
    place.location = coordpair.location;
    if (place && coordpair.location.longitude!= 0){
        [placeAndCoords setObject:place forKey:place_id];
    }

}
//Adds coords from passed in parameters
//Should always be called on exisiting place
-(void)addCoordsLat:(NSString *)lat andLong:(NSString *)lon forPlaceId:(NSString *)placeId{
    //FIXME do I need to re-add object to dictionary, or does it retain pointer so i can update it's features?  For now just re-adding
    Place *place = [self getPlaceFromId:placeId];
    if(place){
        [place addLat:lat andLong:lon];
        [placeAndCoords setObject:place forKey:placeId];
    }
    else{
        DebugLog(@"Warning: adding coords to non exisiting object with id %i", placeId);
    }
   
}


#pragma mark - Debug
-(NSUInteger)getNumPlaces{
    return [idForPlace count];
}
                      
@end
