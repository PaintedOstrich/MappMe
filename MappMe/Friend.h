//
//  Person.h
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationTypeEnum.h"

@interface Friend : NSObject{
    NSString * userId;
    NSString * hometown;
    NSString * currentLocation;
    NSArray * highschool;
    NSArray * college;
    NSArray * gradSchool;
    NSArray * work;
}

@property (nonatomic, retain) NSString *hometown;
@property (nonatomic, retain) NSString *currentLocation;
@property (nonatomic, retain) NSArray * highschool;
@property (nonatomic, retain) NSArray * college;
@property (nonatomic, retain) NSArray * gradSchool;
@property (nonatomic, retain) NSArray * work;
@property (nonatomic, retain) NSString * userId;

-(id)initWithFriend:(NSString *)friendId withPlace:(NSString *)placeId andLocType:(locTypeEnum)placeType;
-(BOOL)hasPlaceId:(NSString *)placeId forType:(locTypeEnum)placeType;
-(void)setPlaceId:(NSString *)placeId forType:(locTypeEnum)placeType;
-(BOOL)hasEntryForType:(locTypeEnum)locType;
-(NSArray *)getArrayEntryForLocType:(locTypeEnum)locType;
-(NSString *)getStringEntryForLocType:(locTypeEnum)locType;

@end
