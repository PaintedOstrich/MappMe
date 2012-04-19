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

@end
