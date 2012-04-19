//
//  PeopleContainer.h
//  MappMe
//
//  Created by Parker Spielman on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationTypeEnum.h"
#import "Person.h"

@interface PeopleContainer : NSObject{

}

-(Person*)get:(NSString*)person_id;
-(Person*) update:uid withName:name;
-(int)count;




///*Parsing methods to update or add entry*/
//-(void)setPersonPlaceInContainer:(NSString *)name personId:(NSString *)personId placeId:(NSString *)placeId andTypeId:(locTypeEnum)locType;
//-(void)addId:(NSString *)personId andPerson:(NSString *)personName;
//
////Main methods called
//-(NSDictionary*)getAndSetFriendGroupingForLocType:(locTypeEnum)locType;
//-(NSDictionary*)getFriendGroupingForLocType:(locTypeEnum)locType;
//-(Person*)getFriendFromId:(NSString *)uid;
//-(NSDictionary *)getCurrentGrouping;
//
////Search method
//-(NSArray *)getFriendsWithName:(NSString *)name;
//
////Additional available methods
////Mapping
//-(NSString *)getIdFromName:(NSString *)placeName;
//-(NSString *)getNameFromId:(NSString *)placeId;
//
////Retrieve all friends
//-(NSArray *)getAllFriendIds;
//-(NSArray *)getAllFriends;
//
//#pragma mark - Debug
//-(NSUInteger)getNumPeople;
//-(void)printCurrentGrouping:(locTypeEnum)locType;
//-(void)printGroupings:(locTypeEnum)locType;
//-(void)printNFriends:(NSUInteger)num;
@end
