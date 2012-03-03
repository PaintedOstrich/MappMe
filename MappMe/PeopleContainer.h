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
}


-(void)setPersonPlaceInContainer:(NSString *)name personId:(NSString *)personId placeId:(NSString *)placeId andTypeId:(locTypeEnum)locType;

-(NSDictionary*)getFriendGroupingForLocType:(locTypeEnum)locType;
-(Friend*)getFriendFromId:(NSString *)uid;
#pragma mark - Debug
-(NSUInteger)getNumPeople;
-(void)printGroupings:(locTypeEnum)locType;
-(void)printNFriends:(NSUInteger)num;
@end
