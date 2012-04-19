//
//  Person.h
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationTypeEnum.h"
#import "Place.h"

@interface Person : NSObject

@property (nonatomic, copy) NSString *profileUrl;
@property (nonatomic, retain) Place *hometown;
@property (nonatomic, retain) Place *currentLocation;
@property (nonatomic, retain) NSMutableArray * highschools;
@property (nonatomic, retain) NSMutableArray * colleges;
@property (nonatomic, retain) NSMutableArray * gradSchools;
@property (nonatomic, retain) NSMutableArray * workPlaces;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * name;
@property  NSUInteger sectionNumber;

-(Person*)initPerson:(NSString*)personId withName:(NSString*)fullName;
-(void)addPlace:(Place*)place withType:(int)locType;







-(id)initWithFriend:(NSString *)friendId withPlace:(NSString *)placeId LocType:(locTypeEnum)placeType andName: (NSString*)friendName;
-(BOOL)hasPlaceId:(NSString *)placeId forType:(locTypeEnum)placeType;
-(void)setPlaceId:(NSString *)placeId forType:(locTypeEnum)placeType;
-(BOOL)hasEntryForType:(locTypeEnum)locType;
-(NSArray *)getArrayEntryForLocType:(locTypeEnum)locType;
-(NSString *)getStringEntryForLocType:(locTypeEnum)locType;

@end
