//
//  UtilFunctions.m
//  MappMe
//
//  Created by Parker Spielman on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UtilFunctions.h"

@implementation UtilFunctions


//Will Convert DecimalNumber and Int to String
+(NSString *)convertToString:(NSObject*)object{
    if ([object isMemberOfClass:[NSString class]]){
        return (NSString*)object;
    }
    if ([object isMemberOfClass:[NSDecimalNumber class]]){
        NSDecimalNumber *num = (NSDecimalNumber *)object;
        return [[NSString alloc] initWithFormat:@"%@",num.stringValue];
    }
    if ([object isMemberOfClass:[NSDecimalNumber class]]){
        NSDecimalNumber *num = (NSDecimalNumber *)object;
        return [[NSString alloc] initWithFormat:@"%@",num.stringValue];
    }
    if ([object isMemberOfClass:[NSNumber class]]){
        NSNumber *num = (NSNumber *)object;
        return [[NSString alloc] initWithFormat:@"%@",num.stringValue];
    }
    NSLog(@"Match not found for %@ ", object);
return [[NSString alloc] initWithFormat:@"%@",object];
    
}


@end
