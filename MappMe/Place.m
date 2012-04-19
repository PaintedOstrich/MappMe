//
//  CoordPairs.m
//  MappMe
//
//  Created by Parker Spielman on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place.h"

@implementation Place

@synthesize location;
@synthesize name;
@synthesize uid;

-(id)initPlace:(NSString *)placeId withName:(NSString*)placeName{
    if(self = [super init]){
        self.name= placeName;
        self.uid = placeId;
    }
    return self;
}
-(void)addLat:(NSString *)lat andLong:(NSString *)lon{
    location.latitude = [lat doubleValue];
    location.longitude = [lon doubleValue];
}


@end
