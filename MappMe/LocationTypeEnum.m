//
//  LocationTypeEnum.m
//  MappMe
//
//  Created by Parker Spielman on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationTypeEnum.h"
#import "DebugLog.h"


@implementation LocationTypeEnum

+(BOOL)isArrayType:(locTypeEnum)locType{
    if (locType == tCurrentLocation || locType == tHomeTown){
        return FALSE;
    }
    return TRUE;
}

+(NSString *)getNameFromEnum:(locTypeEnum)locType{
    switch(locType){
        case tHomeTown:
            return  @"Hometown";
        case tCurrentLocation:
            return  @"Current Location";
        case tHighSchool:
            return @"High School";
        case tCollege:
            return @"College";
        case tGradSchool:
            return @"Grad School";
        case tWork:
            return @"Work";
        default:
            DebugLog(@"Warning: hitting default case");
    }
    return @"";

}
@end
