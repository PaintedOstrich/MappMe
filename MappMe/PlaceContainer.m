//
//  ObjectIdMapping.m
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceContainer.h"
#import "DebugLog.h"


@implementation PlaceContainer{
    NSMutableDictionary* _data;
}

-(id)init{
    if (self = [super init]) {
      _data = [[NSMutableDictionary alloc] initWithCapacity:20];
    }
    return self;
}

/*
 * Return a place object by id. 
 * If this id is not registered, will create a place object with name "No Name" and return it.
 */
-(Place*)get:(NSString*)town_id
{
    Place* place = [_data objectForKey:town_id];
    if (place == nil) {
        place = [[Place alloc] initPlace:town_id withName:@"No Name"];
        [_data setValue:place forKey:town_id];
    }
    return place;
}

-(Place*)update:(NSString*)town_id withName:(NSString*)town_name
{
    Place* place = [self get:town_id];
    place.name = town_name;
    return place;
}

-(Place*)update:(NSString*)town_id withLat:(NSString *)lat andLong:(NSString*)lon
{
    Place* place = [self get:town_id];
    [place addLat:lat andLong:lon];
    return place;
}


/*
 * Return total number of places maintained in PlaceContainer.
 */
-(int)count
{
    return [_data count];
}

-(NSArray*) getPlacesUsedAs:(locTypeEnum)locType
{
    NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:10];
    NSArray* allPlaces = [_data allValues];
    
    for(int i = 0; i < [allPlaces count]; i++) {
        Place* place = [allPlaces objectAtIndex:i];
        NSMutableSet* people = [place getPeople:locType];
        if ([people count] > 0) {
            [result addObject:place];
        }
    }
    return  [result allObjects];
}















//-(void)addId:(NSString *)placeId andPlaceName:(NSString *)placeName{
//    //If empty
//    if([placeForId objectForKey:placeId]== nil) {
//        Place * location = [[Place alloc] initPlaceWithName:placeName];
//        [placeForId setValue:location forKey:placeId];
//        [idForPlace setValue:placeId forKey:placeName];
//    }
//}
//
////Adds coords from Google Maps
////This method currently used for education info
//-(void)doCoordLookupAndSet:(NSString*)place_id withDict:(NSDictionary *)loc andTypeString:(NSString *)placeTypeName{
//    //Get place name from instance Variable
//    Place *place = [self getPlaceFromId:place_id];
//    /*Note: Can Be Nil*/
//    
//    [[CoordinateLookupManager sharedManager] lookupLocation:place.placeName successCB:^(CoordPairsHelper * coordpair) {
//        place.location = coordpair.location;
//        if (place && coordpair.location.longitude!= 0){
//            [placeAndCoords setObject:place forKey:place_id];
//        }
//
//    } failureCB:^(NSError *error) {
//        //TODO
//    }];
//}
////Adds coords from passed in parameters
////Should always be called on exisiting place
//-(void)addCoordsLat:(NSString *)lat andLong:(NSString *)lon forPlaceId:(NSString *)placeId{
//    //FIXME do I need to re-add object to dictionary, or does it retain pointer so i can update it's features?  For now just re-adding
//    Place *place = [self getPlaceFromId:placeId];
//    if(place){
//        [place addLat:lat andLong:lon];
//        [placeAndCoords setObject:place forKey:placeId];
//    }
//    else{
//        DebugLog(@"Warning: adding coords to non exisiting object with id %i", placeId);
//    }
//   
//}
//
//
//#pragma mark - Debug
//-(NSUInteger)getNumPlaces{
//    return [idForPlace count];
//}
                      
@end
