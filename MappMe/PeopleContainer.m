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
#import "DataManagerSingleton.h"

@implementation PeopleContainer{
    NSMutableDictionary* _data;
}


@synthesize people;

-(id)init{
    if(self = [super init]){
        _data = [[NSMutableDictionary alloc] initWithCapacity:20];
    }
    return self;
}

/*
 * Return a person object by id. 
 * If this id is not registered, will create a person object with name "No Name" and return it.
 */
-(Person*)get:(NSString*)person_id
{
    Person* person = [_data objectForKey:person_id];
    if (person == nil) {
        person = [[Person alloc] initPerson:person_id withName:@"No Name"];
        [_data setValue:person forKey:person_id];
    }
    return person;
}

-(Person*) update:uid withName:name
{
    Person* person = [self get:uid];
    person.name = name;
    return person;
}

/*
 * Return total number of people maintained in PeopleContainer.
 */
-(int)count
{
    return [_data count];
}


















//#pragma mark - Logging of updates to user models
//-(void)addEntryToUserInfoLog:(NSString *)userId updateLocation:(NSString *)placeId andType:(locTypeEnum)placeType{
//    DataManagerSingleton * mainDataManager = [DataManagerSingleton sharedManager];
//    [[mainDataManager userInfoLog]addUserInfoUpdate:userId andUpdate:placeId forType:placeType];
//}
//
//#pragma mark - Parsing methods to update or add entry
///*
// Method checks to see if Friend exists, and if Friend has Location Info, 
// If friend doesn't, info is added, and logged
// Adds location info to friend object
// @params name: person name, personid: uid, placeId: placeId, typeId: type being added
// */
//
//-(void)setPersonPlaceInContainer:(NSString *)name personId:(NSString *)personId placeId:(NSString *)placeId andTypeId:(locTypeEnum)locType{
//    NSString * uid = personId;
//    Person *personCmp = [people objectForKey:uid];
//    if(personCmp !=nil){
//        if (![personCmp hasPlaceId:placeId forType:locType]){
//            [personCmp setPlaceId:placeId forType:locType];
//            [self addEntryToUserInfoLog:uid updateLocation:placeId andType:locType];
//        }
//    }else{
//        personCmp = [[Person alloc] initWithFriend:uid withPlace:placeId LocType:locType andName: name];
//        
//        /* Add User Name and Id to Mapping */
//        DataManagerSingleton * mainDataManager = [DataManagerSingleton sharedManager];
//        [mainDataManager.peopleContainer addId:uid andPerson:name];
//    }
//    [people setObject:personCmp forKey:uid];
////    DebugLog(@"After %@", [people objectForKey: uid]);
//}
///* Adds name id mapping, used for fast efficient search and map name to id lookup*/
// -(void)addId:(NSString *)personId andPerson:(NSString *)personName{
//     if([personForId objectForKey:personId]== nil)  {
//         [personForId setValue:personName forKey:personId];
//         [idForPerson setValue:personId forKey:personName];
//     }
// }
//#pragma mark - Retrieving Content Methods
///* @params Method Takes in type of location (enum)
//   @return: Returns dictionary of cities, where k is id, and value is a 
//        set of userId's for those cities
// */
//-(NSDictionary*)getFriendGroupingForLocType:(locTypeEnum)locType{
//    NSMutableDictionary *friendGroupings = [[NSMutableDictionary alloc] init];
//    NSEnumerator *peopleIterator = [people objectEnumerator];
//    Person *tmp;
//    while (tmp = [peopleIterator nextObject]) {
//        if([tmp hasEntryForType:locType]){
//            if ([LocationTypeEnum isArrayType:locType]){
//                NSEnumerator *entryIterator = [[tmp getArrayEntryForLocType:locType] objectEnumerator];
//                NSString *loc;
//                while (loc = [entryIterator nextObject]) {
//                    if ([friendGroupings objectForKey:loc]) {
//                        [[friendGroupings objectForKey:loc]addObject:tmp.userId];
//                    }else{
//                        NSMutableSet *placeSet = [[NSMutableSet alloc] initWithObjects:tmp.userId, nil];
//                        [friendGroupings setObject:placeSet forKey:loc];
//                    }
//                }
//                
//            }
//            else{
//                NSString *loc = [tmp getStringEntryForLocType:locType];
//                if ([friendGroupings objectForKey:loc]) {
//                    [[friendGroupings objectForKey:loc]addObject:tmp.userId];
//                }else{
//                    NSMutableSet *placeSet = [[NSMutableSet alloc] initWithObjects:tmp.userId, nil];
//                    [friendGroupings setObject:placeSet forKey:loc];
//                }
//            }
//        }
//    }
////    [self printCurrentGrouping:locType];
//    return (NSDictionary*)friendGroupings;
//}
////methods sets current grouping, and returns grouping for a location type:
////Method here used to allow concurrent threads to access getFriendGorupingForLocType without affecting the view variables
//-(NSDictionary*)getAndSetFriendGroupingForLocType:(locTypeEnum)locType{
//    currentGrouping = [self getFriendGroupingForLocType:locType];
//    return currentGrouping;
//}
//-(NSDictionary *)getCurrentGrouping{
//    return currentGrouping;
//}
//-(Person*)getFriendFromId:(NSString *)uid{
//    NSDecimalNumber *userId = (NSDecimalNumber *)uid;
//    Person * friend = [people objectForKey:userId];
//    if (friend==nil){
//        DebugLog(@"Warning: friend is missing");
//    }
//    return friend;
//}
//-(NSString *)getNameFromId:(NSString *)placeId{
//    return [personForId objectForKey:placeId];
//}
//-(NSString *)getIdFromName:(NSString *)placeName{
//    return [idForPerson objectForKey:placeName];
//}
//-(NSArray *)getFriendsWithName:(NSString *)name{
//    name = [name lowercaseString];
//    NSMutableArray *friendIds = [[NSMutableArray alloc] init];
//    NSArray *names = [idForPerson allKeys];
//    NSEnumerator *peopleIterator = [names objectEnumerator];
//    NSString *tmpName;
//    while (tmpName = [peopleIterator nextObject]) {
//        NSString *compareName = [tmpName lowercaseString];
//        if ([compareName rangeOfString:name].location != NSNotFound){
//            [friendIds addObject:[idForPerson objectForKey:tmpName]];
//        }
//    }
//    //    DebugLog(@"Returning %i friends matching name : %@",[friendIds count], name);
//    return friendIds;
//}
//-(NSArray *)getAllFriendIds{
//    return [personForId allKeys];
//}
//-(NSArray *)getAllFriends{
//    return [personForId allValues];
//}
//#pragma mark - Debug
//-(void)printCurrentGrouping:(locTypeEnum)locType;{
//    NSDictionary*groupings = currentGrouping;
//    DataManagerSingleton * mainDataManager = [DataManagerSingleton sharedManager];
//    
//    NSArray *keys;
//    int i, count;
//    NSString* place;
//    NSMutableSet *s ;
//    NSMutableString *returnString = [[NSMutableString alloc] initWithFormat:@""];    
//    keys = [groupings allKeys];
//    count = [keys count];
//    for (i = 0; i < count; i++)
//    {
//        place = [keys objectAtIndex: i];
//        s = [groupings objectForKey: place];
//        [returnString appendFormat:@"\n %@",[mainDataManager.placeContainer getPlaceNameFromId:place]];
//        NSEnumerator *setEnum = [s objectEnumerator];
//        NSString *uid;
//        while (uid = [setEnum nextObject]) {
//            [returnString appendFormat:@"\n\t %@", [mainDataManager.peopleContainer getNameFromId:uid]];
//        }
//    }
//    DebugLog(@"%@, \n%@",[LocationTypeEnum getNameFromEnum:locType], returnString);
//}
//-(void)printGroupings:(locTypeEnum)locType{
//    NSDictionary*groupings = [self getFriendGroupingForLocType:locType];
//    DataManagerSingleton * mainDataManager = [DataManagerSingleton sharedManager];
//    
//    NSArray *keys;
//    int i, count;
//    NSString* place;
//    NSMutableSet *s ;
//    NSMutableString *returnString = [[NSMutableString alloc] initWithFormat:@""];
//    
//    keys = [groupings allKeys];
//    count = [keys count];
//    for (i = 0; i < count; i++)
//    {
//        place = [keys objectAtIndex: i];
//        s = [groupings objectForKey: place];
//        [returnString appendFormat:@"\n %@",[mainDataManager.placeContainer getPlaceNameFromId:place]];
//        NSEnumerator *setEnum = [s objectEnumerator];
//        NSString *uid;
//        while (uid = [setEnum nextObject]) {
//            [returnString appendFormat:@"\n\t %@", [mainDataManager.peopleContainer getNameFromId:uid]];
//        }
//    }
//    DebugLog(@"%@, \n%@",[LocationTypeEnum getNameFromEnum:locType], returnString);
//}
//-(NSUInteger)getNumPeople{
//    return [people count];
//}
//-(void)printNFriends:(NSUInteger)num{
//    int index = 0;
//    NSEnumerator *peopleIterator = [people objectEnumerator];
//    Person *tmp;
//    while (tmp = [peopleIterator nextObject]) {
//        if (index == num)
//            break;
//        index++;
//        DebugLog(@"%@",tmp);
//    }
//}


@end
