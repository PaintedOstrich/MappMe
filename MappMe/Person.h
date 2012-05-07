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
@property (nonatomic, copy) NSString *largeProfileUrl;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSArray *mutualFriends;
@property  NSUInteger sectionNumber;

-(Person*)initPerson:(NSString*)personId withName:(NSString*)fullName;
-(void)addPlace:(Place*)place withType:(int)locType;

//Return the internally mainted mapping between locType and array of places.
-(NSDictionary*) getPlacesMapping;

-(NSString*) getFirstName;
@end
