//
//  UtilFunctions.m
//  MappMe
//
//  Created by Parker Spielman on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UtilFunctions.h"
#import <objc/runtime.h>

@implementation UtilFunctions


+(NSString *)convertToString:(id)object{
    if ([object respondsToSelector:@selector(stringValue)]) {
        return [object stringValue];
    } else if([object isKindOfClass:[NSString class]]) {
        //already a string, just return it
        return (NSString*) object;
    }
    
    DebugLog(@"convertToString method does not know how to convert %@ objects into NSString", class_getName([object class]));
    return nil;
}

+(void) setBtnTitleForAllStates:(UIButton*)btn withText:(NSString*)txt 
{
    [btn setTitle:txt forState:UIControlStateNormal];
    [btn setTitle:txt forState:UIControlStateHighlighted];
    [btn setTitle:txt forState:UIControlStateDisabled];
    [btn setTitle:txt forState:UIControlStateSelected];
}

//This method is used in FacebookDataHandler.
//The reason to put it here is that, for some reason, we cannot test FacebookDataHandler
//directly (A linker error for FBConnect.h will be thrown and no good solution is found yet).
//This method will return FALSE if all keys in the loc Dictioanry has empty strings as value.
+(BOOL) hasLoactionData:(NSDictionary*)loc
{
    id tmp;
    NSString* str;
    NSEnumerator *enumerator = [loc objectEnumerator];
    while ((tmp = [enumerator nextObject])) {
        str = [UtilFunctions convertToString:tmp];
        if (str !=nil && [str length] > 0) {
            return TRUE;
        }
    }
    return FALSE;
}


@end
