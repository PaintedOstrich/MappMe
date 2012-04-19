//
//  Person.h
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationTypeEnum.h"

@class Place;
@interface Person : NSObject

@property (nonatomic, copy) NSString *profileUrl;
@property (nonatomic, retain) Place *hometown;
@property (nonatomic, retain) Place *currentLocation;
@property (nonatomic, retain) NSMutableSet * highschools;
@property (nonatomic, retain) NSMutableSet * colleges;
@property (nonatomic, retain) NSMutableSet * gradSchools;
@property (nonatomic, retain) NSMutableSet * workPlaces;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * name;
@property  NSUInteger sectionNumber;

-(Person*)initPerson:(NSString*)personId withName:(NSString*)fullName;
-(void)addPlace:(Place*)place withType:(int)locType;







//-(id)initWithFriend:(NSString *)friendId withPlace:(NSString *)placeId LocType:(locTypeEnum)placeType andName: (NSString*)friendName;
//-(BOOL)hasPlaceId:(NSString *)placeId forType:(locTypeEnum)placeType;
//-(void)setPlaceId:(NSString *)placeId forType:(locTypeEnum)placeType;
//-(BOOL)hasEntryForType:(locTypeEnum)locType;
//-(NSArray *)getArrayEntryForLocType:(locTypeEnum)locType;
//-(NSString *)getStringEntryForLocType:(locTypeEnum)locType;

@end
