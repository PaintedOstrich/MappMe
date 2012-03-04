//
//  LocationTypeEnum.m
//  MappMe
//
//  Created by Parker Spielman on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationTypeEnum.h"


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
            return  
        case tCurrentLocation:
            return 
        case tHighSchool:
            return 
        case tCollege:
            return 
        case tGradSchool:
            return  
        case tWork:
            return 
        default:
            DebugLog(@"Warning: hitting default case");
    }

}
@end
