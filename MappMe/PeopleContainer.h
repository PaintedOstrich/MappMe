//
//  PeopleContainer.h
//  MappMe
//
//  Created by Parker Spielman on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationTypeEnum.h"
#import "Friend.h"

@interface PeopleContainer : NSObject{
    NSMutableDictionary* people;
}

@property (nonatomic, retain) NSMutableDictionary *people;

/*Parsing methods to update or add entry*/
-(void)setPersonPlaceInContainer:(NSString *)name personId:(NSString *)personId placeId:(NSString *)placeId andTypeId:(locTypeEnum)locType;
-(void)addId:(NSString *)personId andPerson:(NSString *)personName;

//Main methods called
-(NSDictionary*)getFriendGroupingForLocType:(locTypeEnum)locType;
-(Friend*)getFriendFromId:(NSString *)uid;
-(NSDictionary *)getCurrentGrouping;

//Search method
-(NSArray *)getFriendsWithName:(NSString *)name;

//Additional available methods
//Mapping
-(NSString *)getIdFromName:(NSString *)placeName;
-(NSString *)getNameFromId:(NSString *)placeId;

//Retrieve all friends
-(NSArray *)getAllFriendIds;
-(NSArray *)getAllFriends;

#pragma mark - Debug
-(NSUInteger)getNumPeople;
-(void)printGroupings:(locTypeEnum)locType;
-(void)printNFriends:(NSUInteger)num;
@end
