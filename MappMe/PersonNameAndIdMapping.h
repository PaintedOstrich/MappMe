//
//  PersonNameAndIdMapping.h
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonNameAndIdMapping : NSObject{
    
}
-(NSString *)getIdFromName:(NSString *)placeName;
-(NSString *)getNameFromId:(NSString *)placeId;
-(void)addId:(NSString *)personId andPerson:(NSString *)personName;

-(NSArray *)getFriendsWithName:(NSString *)name;
@end
