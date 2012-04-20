//
//  CoordPairs.m
//  MappMe
//
//  Created by Parker Spielman on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoordPairsHelper.h"

@implementation CoordPairsHelper

@synthesize location;

-(id)initWithLat:(NSString *)lat andLong:(NSString *)lon{
    if (self =[super init]){
        location.latitude = [lat doubleValue];
        location.longitude = [lon doubleValue];
    }
    return self;
}

-(NSString*) latAsString
{
    NSString* str = [NSString stringWithFormat:@"%f", location.latitude];
    return str;
}

-(NSString*) longAsString
{
    NSString* str = [NSString stringWithFormat:@"%f", location.longitude];
    return str;
}

@end