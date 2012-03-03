//
//  UserInfoLog.h
//  MappMe
//
//  Created by Parker Spielman on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "LocationTypeEnum.h"

@interface UserInfoLog : NSObject

-(void)printLog;
-(void)addUserInfoUpdate:(NSString*)userId andUpdate:(NSString *)placeId forType:(locTypeEnum)placeType;


@end
