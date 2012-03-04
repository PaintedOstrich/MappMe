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
    NSMutableDictionary *people;

}


-(id)init{
    if(self = [super init]){
        people = [[NSMutableDictionary alloc]initWithCapacity:20];
    }
    return self;
}

-(void)addEntryToUserInfoLog:(NSString *)userId updateLocation:(NSString *)placeId andType:(locTypeEnum)placeType{
    MappMeAppDelegate *delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[delegate userInfoLog]addUserInfoUpdate:userId andUpdate:placeId forType:placeType];
}

/*
 Method checks to see if Friend exists, and if Friend has Location Info, 
 If friend doesn't, info is added, and logged
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
        personCmp = [[Friend alloc] initWithFriend:uid withPlace:placeId andLocType:locType];
        
        /* Add User Name and Id to Mapping */
         MappMeAppDelegate *delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.personNameAndIdMapping addId:uid andPerson:name];
    }
    [people setObject:personCmp forKey:uid];
//    DebugLog(@"After %@", [people objectForKey: uid]);
}

#pragma mark - Retrieving Content Methods
/* @params Method Takes in type of location (enum)
   @return: Returns dictionary of cities, where k is id, and value is a 
        set of userId's for those cities
 */
-(NSDictionary*)getFriendGroupingForLocType:(locTypeEnum)locType{
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
                    [friendGroupings setValue:placeSet forKey:loc];
                }
            }
        }
    }
    return (NSDictionary*)friendGroupings;
}
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
        [returnString appendFormat:@"\n %@",[delegate.placeIdMapping getPlaceFromId:place]];
        NSEnumerator *setEnum = [s objectEnumerator];
        NSString *uid;
        while (uid = [setEnum nextObject]) {
            [returnString appendFormat:@"\n\t %@", [delegate.personNameAndIdMapping getNameFromId:uid]];
        }
    }
    DebugLog(@"%@", (NSString*)returnString);
}

-(Friend*)getFriendFromId:(NSString *)uid{
    Friend * friend = [people objectForKey:uid];
    if (friend==nil){
        DebugLog(@"friend is missing");
    }
    return (Friend*)[people objectForKey:uid];
}
#pragma mark - Debug
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
