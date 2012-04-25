//
//  ObjectIdMapping.m
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceContainer.h"
#import "DebugLog.h"


@implementation PlaceContainer {
    NSString* _path;
}

-(id)init
{
    if(self = [super init]){
        [self setupPath];
    }
    return self;
}

#pragma mark - Persistence code

-(void)setupPath
{
    NSString *documentsDirectory = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    _path = [documentsDirectory stringByAppendingPathComponent:@"places.dat"];
    NSLog(@"Saving places in %@", _path);
}

-(void) loadPlacesFromDisk
{
    NSDictionary* places = [NSKeyedUnarchiver unarchiveObjectWithFile:_path];
    if (!places) {
        DebugLog(@"Did not have places persistent file set up");
    } else {
          DebugLog(@"Loaded %d places from disk!", [places count]);
//        DebugLog(@"%@", [places allValues]);
        NSEnumerator *enumerator = [places keyEnumerator];
        id key;
        while ((key = [enumerator nextObject])) {
            Place* p = [places objectForKey:key];
            [self get:key].location = p.location;
            [self get:key].name = p.name;
        }
    }
}

-(void) savePlacesToDisk
{
    [NSKeyedArchiver archiveRootObject:_data toFile:_path];
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
