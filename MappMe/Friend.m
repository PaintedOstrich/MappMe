//
//  Person.m
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Friend.h"
#import "DebugLog.h"
#import "MappMeAppDelegate.h"


@implementation Friend

@synthesize hometown;
@synthesize currentLocation;
@synthesize highschool;
@synthesize college;
@synthesize gradSchool;
@synthesize work;
@synthesize userId;


-(id)initWithFriend:(NSString *)friendId withPlace:(NSString *)placeId andLocType:(locTypeEnum)placeType{
    if (self = [super init]) {
        switch(placeType){
            case tHomeTown:
                self.hometown = placeId;
                break;
            case tCurrentLocation:
                self.currentLocation = placeId;
                break;
            case tHighSchool:
                self.highschool = [[NSArray alloc] initWithObjects:placeId, nil];
                break;
            case tCollege:
                self.college = [[NSArray alloc] initWithObjects:placeId, nil];
                break;
            case tGradSchool:
                self.gradSchool = [[NSArray alloc] initWithObjects:placeId, nil];
                break;
            case tWork:
                self.work = [[NSArray alloc] initWithObjects:placeId, nil];
                break;
            default:{
                DebugLog(@"Warning: hitting default case");
            }
        }
    }
    self.userId = friendId;
    return self;
}
-(BOOL)hasPlaceId:(NSString *)placeId forType:(locTypeEnum)placeType{
/*FIXME Objective C bug:  placeId and self.* cast to NSDecimal Number*/
   
    switch(placeType){
        case tHomeTown:
            return self.hometown == placeId;
        case tCurrentLocation:
            return self.currentLocation == placeId;
        case tHighSchool:
        {
            NSEnumerator *e = [self.highschool objectEnumerator];
            NSString *entry;
            while (entry = (NSString*)[e nextObject]) {
                if (entry ==placeId){
                    return true;
                }
            }
        }
        case tCollege:
        {
            NSEnumerator *e = [self.college objectEnumerator];
            NSString *entry;
            while (entry = (NSString*)[e nextObject]) {
                if (entry ==placeId){
                    return true;
                }
            }
        }
        case tGradSchool:
        {
            NSEnumerator *e = [self.gradSchool objectEnumerator];
            NSString *entry;
            while (entry = (NSString*)[e nextObject]) {
                if (entry ==placeId){
                    return true;
                }
            }
        }
        case tWork:
        {
            NSEnumerator *e = [self.highschool objectEnumerator];
            NSString *entry;
            while (entry = (NSString*)[e nextObject]) {
                if (entry ==placeId){
                    return true;
                }
            }
        }
        default:{
            DebugLog(@"Warning: hitting default case");
        }
    }
    return false;
}
-(void)setPlaceId:(NSString *)placeId forType:(locTypeEnum)placeType{
    switch(placeType){
        case tHomeTown:
            self.hometown = placeId;  
            break;
        case tCurrentLocation:
            self.currentLocation = placeId;
            break;
        case tHighSchool:
        {
            NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:self.highschool];
            [tmp addObject:placeId];
            self.highschool =(NSArray*)tmp;
            break;
        }
        case tCollege:
        {
            NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:self.college];
            [tmp addObject:placeId];
            self.college =(NSArray*)tmp;
            break;
        }
        case tGradSchool:
        {
            NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:self.gradSchool];
            [tmp addObject:placeId];
            self.gradSchool =(NSArray*)tmp;
            break;
        }
        case tWork:
        {
            NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:self.work];
            [tmp addObject:placeId];
            self.work =(NSArray*)tmp;
            break;
        }
        default:{
            DebugLog(@"Warning: hitting default case");
        }

    }
    return;
}
-(BOOL)hasEntryForType:(locTypeEnum)locType{
    switch(locType){
        case tHomeTown:
            return self.hometown != nil;  
        case tCurrentLocation:
            return self.currentLocation != nil;
        case tHighSchool:
            return self.highschool != nil;
        case tCollege:
           return self.college != nil;
        case tGradSchool:
          return self.gradSchool != nil;      
        case tWork:
          return self.work != nil;
        default:
            DebugLog(@"Warning: hitting default case");
    }
    return FALSE;
}
-(NSString *)getStringEntryForLocType:(locTypeEnum)locType{
    switch(locType){
        case tHomeTown:
            return self.hometown;  
        case tCurrentLocation:
            return self.currentLocation;
        default:
            DebugLog(@"Warning: hitting default case");
    }
    return nil;
}
-(NSArray *)getArrayEntryForLocType:(locTypeEnum)locType{
    switch(locType){
        case tHighSchool:
            return self.highschool;
        case tCollege:
            return self.college;
        case tGradSchool:
            return self.gradSchool;      
        case tWork:
            return self.work;
        default:
            DebugLog(@"Warning: hitting default case");
    }
    return nil;
}
- (NSString *)description{
    MappMeAppDelegate *delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableString *person = [[NSMutableString alloc] initWithString:@"\n"];
    [person appendString:[delegate.personNameAndIdMapping getNameFromId:self.userId]];
    [person appendFormat:@"\n\t uid: %@",self.userId];
    if (self.currentLocation!= nil){
        NSString *placeName = [delegate.placeIdMapping getPlaceFromId:self.currentLocation];
        [person appendFormat:@"\n\t Current Location: %@",placeName];
    }
//    if (self.hometown.length>0){
    if (self.hometown!=nil) {
        NSString *placeName = [delegate.placeIdMapping getPlaceFromId:self.hometown];
        [person appendFormat:@"\n\t HomeTown: %@",placeName];
    }

    return (NSString *)person;    
}




@end