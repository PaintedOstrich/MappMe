//
//  Person.h
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationTypeEnum.h"

@interface Friend : NSObject

@property (nonatomic, copy) NSString *profileUrl;
@property (nonatomic, retain) NSString *hometown;
@property (nonatomic, retain) NSString *currentLocation;
@property (nonatomic, retain) NSArray * highschool;
@property (nonatomic, retain) NSArray * college;
@property (nonatomic, retain) NSArray * gradSchool;
@property (nonatomic, retain) NSArray * work;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * name;
@property  NSUInteger sectionNumber;

-(id)initWithFriend:(NSString *)friendId withPlace:(NSString *)placeId LocType:(locTypeEnum)placeType andName: (NSString*)friendName;
-(BOOL)hasPlaceId:(NSString *)placeId forType:(locTypeEnum)placeType;
-(void)setPlaceId:(NSString *)placeId forType:(locTypeEnum)placeType;
-(BOOL)hasEntryForType:(locTypeEnum)locType;
-(NSArray *)getArrayEntryForLocType:(locTypeEnum)locType;
-(NSString *)getStringEntryForLocType:(locTypeEnum)locType;

@end
