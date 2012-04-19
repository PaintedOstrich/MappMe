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
#import "DataManagerSingleton.h"


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
        self.highschools = [[NSMutableArray alloc] initWithCapacity:5];
        self.colleges = [[NSMutableArray alloc] initWithCapacity:5];
        self.workPlaces = [[NSMutableArray alloc] initWithCapacity:5];
        self.gradSchools = [[NSMutableArray alloc] initWithCapacity:5];
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


//
///*NOTE:  placeId is implicitly Cast to NSDecimalNumber, 
// so comparisons were changed from isEqualToString to simply == 
// */
//-(BOOL)hasPlaceId:(NSString *)placeId forType:(locTypeEnum)placeType{
///*FIXME Objective C bug:  placeId and self.* cast to NSDecimal Number*/
//   
//    switch(placeType){
//        case tHomeTown:
//            return self.hometown == placeId;
//        case tCurrentLocation:
//            return self.currentLocation == placeId;
//        case tHighSchool:
//        {
//            NSEnumerator *e = [self.highschool objectEnumerator];
//            NSString *entry;
//            while (entry = (NSString*)[e nextObject]) {
//
//                if (entry == placeId){
//                    return true;
//                }
//            }
//            return FALSE;
//        }
//        case tCollege:
//        {
//            NSEnumerator *e = [self.college objectEnumerator];
//            NSString *entry;
//            while (entry = (NSString*)[e nextObject]) {
//                if (entry == placeId){
//                    return true;
//                }
//            }
//            return FALSE;
//        }
//        case tGradSchool:
//        {
//            NSEnumerator *e = [self.gradSchool objectEnumerator];
//            NSString *entry;
//            while (entry = (NSString*)[e nextObject]) {
//                if (entry == placeId){
//                    return true;
//                }
//            }
//            return FALSE;
//        }
//        case tWork:
//        {
//            NSEnumerator *e = [self.highschool objectEnumerator];
//            NSString *entry;
//            while (entry = (NSString*)[e nextObject]) {
//                if (entry == placeId){
//                    return true;
//                }
//            }
//            return FALSE;
//        }
//        default:{
//            DebugLog(@"Warning: hitting default case");
//        }
//    }
//    return false;
//}
//-(void)setPlaceId:(NSString *)placeId forType:(locTypeEnum)placeType{
//    switch(placeType){
//        case tHomeTown:
//            self.hometown = placeId;  
//            break;
//        case tCurrentLocation:
//            self.currentLocation = placeId;
//            break;
//        case tHighSchool:
//        {
//            NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:self.highschool];
//            [tmp addObject:placeId];
//            self.highschool =(NSArray*)tmp;
//            break;
//        }
//        case tCollege:
//        {
//            NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:self.college];
//            [tmp addObject:placeId];
//            self.college =(NSArray*)tmp;
//            break;
//        }
//        case tGradSchool:
//        {
//            NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:self.gradSchool];
//            [tmp addObject:placeId];
//            self.gradSchool =(NSArray*)tmp;
//            break;
//        }
//        case tWork:
//        {
//            NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:self.work];
//            [tmp addObject:placeId];
//            self.work =(NSArray*)tmp;
//            break;
//        }
//        default:{
//            DebugLog(@"Warning: hitting default case");
//        }
//
//    }
//    return;
//}
//-(BOOL)hasEntryForType:(locTypeEnum)locType{
//    switch(locType){
//        case tHomeTown:
//            return self.hometown != nil;  
//        case tCurrentLocation:
//            return self.currentLocation != nil;
//        case tHighSchool:
//            return self.highschool != nil;
//        case tCollege:
//           return self.college != nil;
//        case tGradSchool:
//          return self.gradSchool != nil;      
//        case tWork:
//          return self.work != nil;
//        default:
//            DebugLog(@"Warning: hitting default case for loctype: %i", locType);
//    }
//    return FALSE;
//}
//-(NSString *)getStringEntryForLocType:(locTypeEnum)locType{
//    switch(locType){
//        case tHomeTown:
//            return self.hometown;  
//        case tCurrentLocation:
//            return self.currentLocation;
//        default:
//            DebugLog(@"Warning: hitting default case");
//    }
//    return nil;
//}
//-(NSArray *)getArrayEntryForLocType:(locTypeEnum)locType{
//    switch(locType){
//        case tHighSchool:
//            return self.highschool;
//        case tCollege:
//            return self.college;
//        case tGradSchool:
//            return self.gradSchool;      
//        case tWork:
//            return self.work;
//        default:
//            DebugLog(@"Warning: hitting default case");
//    }
//    return nil;
//}
//- (NSString *)description{
//    DataManagerSingleton * mainDataManager = [DataManagerSingleton sharedManager];
//    NSMutableString *person = [[NSMutableString alloc] initWithString:@"\n"];
//    [person appendString:[mainDataManager.peopleContainer getNameFromId:self.uid]];
//    [person appendFormat:@"\n\t uid: %@",self.uid];
//    if (self.currentLocation!= nil){
//        NSString *placeName = [mainDataManager.placeContainer getPlaceNameFromId:self.currentLocation];
//        [person appendFormat:@"\n\t Current Location: %@",placeName];
//    }
//    if (self.hometown!=nil) {
//        NSString *placeName = [mainDataManager.placeContainer getPlaceNameFromId:self.hometown];
//        [person appendFormat:@"\n\t HomeTown: %@",placeName];
//    }
//    if (self.highschool!=nil) {
//        NSEnumerator *e = [self.highschool objectEnumerator];
//        NSString *entry;
//        while (entry = (NSString*)[e nextObject]){
//            NSString *placeName = [mainDataManager.placeContainer getPlaceNameFromId:entry];
//            [person appendFormat:@"\n\t High School: %@",placeName];
//        }
//    }
//    if (self.college!=nil) {
//        NSEnumerator *e = [self.college objectEnumerator];
//        NSString *entry;
//        while (entry = (NSString*)[e nextObject]){
//            NSString *placeName = [mainDataManager.placeContainer getPlaceNameFromId:entry];
//            [person appendFormat:@"\n\t College: %@",placeName];
//        }
//
//    }
//    if (self.gradSchool!=nil) {
//        NSEnumerator *e = [self.gradSchool objectEnumerator];
//        NSString *entry;
//        while (entry = (NSString*)[e nextObject]){
//            NSString *placeName = [mainDataManager.placeContainer getPlaceNameFromId:entry];
//            [person appendFormat:@"\n\t Graduate School: %@",placeName];
//        }
//    }
//
//    return (NSString *)person;    
//}




@end