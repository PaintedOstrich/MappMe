//
//  UserInfoLog.m
//  MappMe
//
//  Created by Parker Spielman on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserInfoLog.h"
#import "DebugLog.h"

@implementation UserInfoLog{
    NSMutableDictionary *userInfoLog;
}

-(id)init{
    if (self = [super init]){
        
        NSMutableArray* container = [[NSMutableArray alloc] init];
        NSMutableArray* container1 = [[NSMutableArray alloc] init];
        NSMutableArray* container2 = [[NSMutableArray alloc] init];
        NSArray * objects   = [NSArray arrayWithObjects:
                           container, container1,container2, nil];
        
        NSArray * keys = [NSArray arrayWithObjects:
                            @"locationInfo", @"behaviorInfo",@"usageInfo", nil];

        userInfoLog = [[NSMutableDictionary alloc] initWithObjects:objects
                                                           forKeys:keys];
    }
    return self;
}
-(void)addUserInfoUpdate:(NSString*)userId andUpdate:(NSString *)placeId forType:(locTypeEnum)placeType{ 
    NSArray *item = [NSArray arrayWithObjects:userId,placeId, nil];
    [[userInfoLog objectForKey:@"locationInfo"]addObject:item];
}


-(void)sendLogInfoToServer{
    
}
-(void)createJsonArrayOfLogInfo{
    
}

-(void)printLog{
    NSEnumerator *e = [userInfoLog objectEnumerator];
    NSString * entry;
    NSLog(@"user Info Log");
    while (entry = (NSString *)[e nextObject]) {
        NSLog(@"%@",entry);
    }
}
@end
