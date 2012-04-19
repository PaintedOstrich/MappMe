//
//  Person.m
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Person.h"
#import "DebugLog.h"
//#import "MappMeAppDelegate.h"
//#import "DataManagerSingleton.h"


@implementation Person

@synthesize hometown;
@synthesize currentLocation;
@synthesize highschools;
@synthesize colleges;
@synthesize gradSchools;
@synthesize workPlaces;
@synthesize uid;
@synthesize name, sectionNumber;
@synthesize profileUrl;


-(NSString*) buildProfileUrl
{
    NSString* urlStr = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", self.uid];
    return urlStr;
}

-(id)initPerson:(NSString*)personId withName:(NSString*)fullName
{
    if(self = [super init]){
        self.name= fullName;
        self.uid = personId;
        self.profileUrl = [self buildProfileUrl];
        self.highschools = [[NSMutableSet alloc] initWithCapacity:5];
        self.colleges = [[NSMutableSet alloc] initWithCapacity:5];
        self.workPlaces = [[NSMutableSet alloc] initWithCapacity:5];
        self.gradSchools = [[NSMutableSet alloc] initWithCapacity:5];
    }
    return self;
}

-(void)addPlace:(Place*)place withType:(int)locType
{
    switch(locType){
        case tHomeTown:
            self.hometown = place;
            break;
        case tCurrentLocation:
            self.currentLocation = place;
            break;
        case tHighSchool:
            [self.highschools addObject:place];
            break;
        case tCollege:
            [self.colleges addObject:place];
            break;
        case tGradSchool:
            [self.gradSchools addObject:place];
            break;
        case tWork:
            [self.workPlaces addObject:place];
            break;
        default:{
            DebugLog(@"Warning: hitting default case");
        }
    }
}

@end