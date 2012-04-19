//
//  CoordPairs.m
//  MappMe
//
//  Created by Parker Spielman on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place.h"

@implementation Place {
    //Mapping from locType to an array of person.
    NSMutableDictionary* _mapping;
}

@synthesize location;
@synthesize name;
@synthesize uid;

-(id)initPlace:(NSString *)placeId withName:(NSString*)placeName{
    if(self = [super init]){
        self.name= placeName;
        self.uid = placeId;
        _mapping = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    return self;
}

-(void)addLat:(NSString *)lat andLong:(NSString *)lon{
    location.latitude = [lat doubleValue];
    location.longitude = [lon doubleValue];
}

-(NSMutableSet*)getPeople:(locTypeEnum)locType
{
    NSString* key = [NSString stringWithFormat:@"%d", locType];
    NSMutableSet* peopleSet = [_mapping objectForKey:key];
    if (peopleSet == nil) {
        peopleSet = [[NSMutableSet alloc] initWithCapacity:5];
        [_mapping setValue:peopleSet forKey:key];
    }
    return peopleSet;
}

-(void)addPerson:(Person*)person forType:(locTypeEnum)locType
{
    NSMutableSet* peopleSet = [self getPeople:locType];
    [peopleSet addObject:person];
}


@end
