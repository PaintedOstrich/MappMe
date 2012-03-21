//
//  PersonNameAndIdMapping.m
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PersonNameAndIdMapping.h"
#import "Friend.h"
#import "DebugLog.h"
@implementation PersonNameAndIdMapping{
    NSMutableDictionary *idForPerson;
    NSMutableDictionary *personForId;
}


-(id)init{
    if (self = [super init]) {
        personForId = [[NSMutableDictionary alloc] init];
        idForPerson = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)addId:(NSString *)personId andPerson:(NSString *)personName{
    if([personForId objectForKey:personId]== nil)  {
        [personForId setValue:personName forKey:personId];
        [idForPerson setValue:personId forKey:personName];
    }
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
#pragma mark - testing methods
-(NSArray *)getAllFriendIds{
    return [personForId allKeys];
}


@end
