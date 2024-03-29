//
//  ObjectIdMapping.m
//  MappMe
//
//  Created by Di Peng on 04/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceContainer.h"
#import "DebugLog.h"


@implementation PlaceContainer {
    NSString* _path;
    NSString* _blacklistPath;
}

@synthesize blacklistedPlaces;

-(id)init
{
    if(self = [super init]){
        blacklistedPlaces = [[NSMutableSet alloc] initWithCapacity:10];
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
    _blacklistPath = [documentsDirectory stringByAppendingPathComponent:@"blacklistplaces.dat"];
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
    
    NSSet* blacklist = [NSKeyedUnarchiver unarchiveObjectWithFile:_blacklistPath];
    if (!blacklist) {
        DebugLog(@"Did not have black listed places file set up");
    } else {
        DebugLog(@"Loaded %d blacked listed places from disk! They are all unlikely to be found on Google Map", [blacklist count]);
        //        DebugLog(@"%@", [places allValues]);
        NSArray* list = [blacklist allObjects];
        for(int i = 0; i < [list count]; i++){
            NSString* placeId =  [list objectAtIndex:i];
            [blacklistedPlaces addObject:placeId];
        }
    }
}

-(void) savePlacesToDisk
{
    [NSKeyedArchiver archiveRootObject:_data toFile:_path];
    [NSKeyedArchiver archiveRootObject:blacklistedPlaces toFile:_blacklistPath];
}

/*
 * Return a place object by id. 
 * If this id is not registered, will create a place object with name "No Name" and return it.
 */
-(Place*)get:(NSString*)town_id
{
    //We should never pass along nil as person_id
    if (town_id == nil) {
        [NSException raise:@"town_id is nil" format:@"town_id cannot be nil when calling get on PlaceContainer"];
    }
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
//Should Find best way to combine these two functions. is it through two wrapper caller functions, storing private variables, or....  only one line of code is different
-(NSArray*) getPlacesUsedAs:(locTypeEnum)locType friendsWith:(Person*)mutualFriendsWith{
    NSMutableSet* result = [[NSMutableSet alloc] initWithCapacity:10];
    NSArray* allPlaces = [_data allValues];
    
    for(int i = 0; i < [allPlaces count]; i++) {
        Place* place = [allPlaces objectAtIndex:i];
        NSMutableSet* allPeople = [place getPeople:locType];
        NSMutableArray *mutualPeople = [[NSMutableArray alloc] init];
        NSEnumerator *friendEnum = [allPeople objectEnumerator];
        Person *friend;
        while (friend = (Person*)[friendEnum nextObject]) {
            if ([mutualFriendsWith.mutualFriends indexOfObject:friend.uid]!=NSNotFound) {
                [mutualPeople addObject:friend];
            }
        }
//        check if mutualFriends are in this place
        if ([mutualPeople count] > 0) {
            [result addObject:place];
        }
    }
    return  [result allObjects];
}
@end
