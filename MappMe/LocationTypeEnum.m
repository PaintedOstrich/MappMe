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

@end
