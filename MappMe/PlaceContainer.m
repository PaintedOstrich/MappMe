//
//  ObjectIdMapping.m
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceContainer.h"
#import "DebugLog.h"


@implementation PlaceContainer

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
@end
