//
//  CoordPairs.h
//  MappMe
//
//  Created by Parker Spielman on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Person.h"

@interface Place : NSObject <NSCoding>{
    CLLocationCoordinate2D location;
    NSString *name;
    NSString* uid;
}

@property(nonatomic)CLLocationCoordinate2D location;
@property(nonatomic,retain) NSString * name;
@property(nonatomic,retain) NSString * uid;


-(id)initPlace:(NSString *)placeId withName:(NSString*)placeName;
-(void)addLat:(NSString *)lat andLong:(NSString *)lon;
-(void) addMetaData:(NSDictionary*)locInfo;

//Get the set of people using this place as the specified locType.
//We use set over array as set will keep Person objects added unique.
-(NSMutableSet*)getPeople:(locTypeEnum)locType;

//Link this person with this place. (e.g. add Tom forType home_town means that
// this place is Tom's home_town).
-(void)addPerson:(Person *)person forType:(locTypeEnum)locType;

//Some scholl address has meta data(state, country, zip code etc.) 
//We ll decide what we mean by full address and return it for a better Google Map look up.
-(NSString*) getFullAddress;

-(BOOL)hasValidLocation;
@end
