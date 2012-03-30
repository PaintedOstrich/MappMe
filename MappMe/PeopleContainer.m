//
//  PeopleContainer.m
//  MappMe
//
//  Created by Parker Spielman on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PeopleContainer.h"
#import "MappMeAppDelegate.h"
#import "DebugLog.h"

@implementation PeopleContainer{
    NSDictionary *currentGrouping;
    
    //Mapping Dictionaries
    NSMutableDictionary *idForPerson;
    NSMutableDictionary *personForId;
    
}

@synthesize people;

-(id)init{
    if(self = [super init]){
        people = [[NSMutableDictionary alloc]initWithCapacity:20];
        personForId = [[NSMutableDictionary alloc] initWithCapacity:20];
        idForPerson = [[NSMutableDictionary alloc] initWithCapacity:20];
    }
    return self;
}
#pragma mark - Logging of updates to user models
-(void)addEntryToUserInfoLog:(NSString *)userId updateLocation:(NSString *)placeId andType:(locTypeEnum)placeType{
    MappMeAppDelegate *delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[delegate userInfoLog]addUserInfoUpdate:userId andUpdate:placeId forType:placeType];
}

#pragma mark - Parsing methods to update or add entry
/*
 Method checks to see if Friend exists, and if Friend has Location Info, 
 If friend doesn't, info is added, and logged
 Adds location info to friend object
 @params name: person name, personid: uid, placeId: placeId, typeId: type being added
 */

-(void)setPersonPlaceInContainer:(NSString *)name personId:(NSString *)personId placeId:(NSString *)placeId andTypeId:(locTypeEnum)locType{
    NSString * uid = personId;
    Friend *personCmp = [people objectForKey:uid];
    if(personCmp !=nil){
        if (![personCmp hasPlaceId:placeId forType:locType]){
            [personCmp setPlaceId:placeId forType:locType];
            [self addEntryToUserInfoLog:uid updateLocation:placeId andType:locType];
        }
    }else{
        personCmp = [[Friend alloc] initWithFriend:uid withPlace:placeId LocType:locType andName: name];
        
        /* Add User Name and Id to Mapping */
         MappMeAppDelegate *delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.peopleContainer addId:uid andPerson:name];
    }
    [people setObject:personCmp forKey:uid];
//    DebugLog(@"After %@", [people objectForKey: uid]);
}
/* Adds name id mapping, used for fast efficient search and map name to id lookup*/
 -(void)addId:(NSString *)personId andPerson:(NSString *)personName{
     if([personForId objectForKey:personId]== nil)  {
         [personForId setValue:personName forKey:personId];
         [idForPerson setValue:personId forKey:personName];
     }
 }
#pragma mark - Retrieving Content Methods
/* @params Method Takes in type of location (enum)
   @return: Returns dictionary of cities, where k is id, and value is a 
        set of userId's for those cities
 */
-(NSDictionary*)getFriendGroupingForLocType:(locTypeEnum)locType{
//    DebugLog(@"Loct Type : %@",[LocationTypeEnum getNameFromEnum:locType]);
    NSMutableDictionary *friendGroupings = [[NSMutableDictionary alloc] init];
    NSEnumerator *peopleIterator = [people objectEnumerator];
    Friend *tmp;
    while (tmp = [peopleIterator nextObject]) {
        if([tmp hasEntryForType:locType]){
            if ([LocationTypeEnum isArrayType:locType]){
                NSEnumerator *entryIterator = [[tmp getArrayEntryForLocType:locType] objectEnumerator];
                NSString *loc;
                while (loc = [entryIterator nextObject]) {
                    if ([friendGroupings objectForKey:loc]) {
                        [[friendGroupings objectForKey:loc]addObject:tmp.userId];
                    }else{
                        NSMutableSet *placeSet = [[NSMutableSet alloc] initWithObjects:tmp.userId, nil];
                        [friendGroupings setObject:placeSet forKey:loc];
                    }
                }
                
            }
            else{
                NSString *loc = [tmp getStringEntryForLocType:locType];
                if ([friendGroupings objectForKey:loc]) {
                    [[friendGroupings objectForKey:loc]addObject:tmp.userId];
                }else{
                    NSMutableSet *placeSet = [[NSMutableSet alloc] initWithObjects:tmp.userId, nil];
                    [friendGroupings setObject:placeSet forKey:loc];
                }
            }
        }
    }
    currentGrouping = (NSDictionary *)friendGroupings;
    return currentGrouping;
}
-(NSDictionary *)getCurrentGrouping{
    return currentGrouping;
}
-(Friend*)getFriendFromId:(NSString *)uid{
    NSDecimalNumber *userId = (NSDecimalNumber *)uid;
    Friend * friend = [people objectForKey:userId];
    if (friend==nil){
        DebugLog(@"Warning: friend is missing");
    }
    return friend;
}
-(NSString *)getNameFromId:(NSString *)placeId{
    return [personForId objectForKey:placeId];
}
-(NSString *)getIdFromName:(NSString *)placeName{
    return [idForPerson objectForKey:placeName];
}
-(NSArray *)getFriendsWithName:(NSString *)name{
    name = [name lowercaseString];
    NSMutableArray *friendIds = [[NSMutableArray alloc] init];
    NSArray *names = [idForPerson allKeys];
    NSEnumerator *peopleIterator = [names objectEnumerator];
    NSString *tmpName;
    while (tmpName = [peopleIterator nextObject]) {
        NSString *compareName = [tmpName lowercaseString];
        if ([compareName rangeOfString:name].location != NSNotFound){
            [friendIds addObject:[idForPerson objectForKey:tmpName]];
        }
    }
    //    DebugLog(@"Returning %i friends matching name : %@",[friendIds count], name);
    return friendIds;
}
-(NSArray *)getAllFriendIds{
    return [personForId allKeys];
}
-(NSArray *)getAllFriends{
    return [personForId allValues];
}
#pragma mark - Debug
-(void)printGroupings:(locTypeEnum)locType{
    NSDictionary*groupings = [self getFriendGroupingForLocType:locType];
    MappMeAppDelegate *delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray *keys;
    int i, count;
    NSString* place;
    NSMutableSet *s ;
    NSMutableString *returnString = [[NSMutableString alloc] initWithFormat:@""];
    
    keys = [groupings allKeys];
    count = [keys count];
    for (i = 0; i < count; i++)
    {
        place = [keys objectAtIndex: i];
        s = [groupings objectForKey: place];
        [returnString appendFormat:@"\n %@",[delegate.placeContainer getPlaceNameFromId:place]];
        NSEnumerator *setEnum = [s objectEnumerator];
        NSString *uid;
        while (uid = [setEnum nextObject]) {
            [returnString appendFormat:@"\n\t %@", [delegate.peopleContainer getNameFromId:uid]];
        }
    }
}
-(NSUInteger)getNumPeople{
    return [people count];
}
-(void)printNFriends:(NSUInteger)num{
    int index = 0;
    NSEnumerator *peopleIterator = [people objectEnumerator];
    Friend *tmp;
    while (tmp = [peopleIterator nextObject]) {
        if (index == num)
            break;
        index++;
        DebugLog(@"%@",tmp);
    }
}


@end
