//
//  LocationTypeEnum.h
//  MappMe
//
//  Created by Parker Spielman on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum locTypeEnum {
  tCurrentLocation,
  tHomeTown,
  tHighSchool,
  tCollege,
  tGradSchool,
  tWork
} locTypeEnum;

@interface LocationTypeEnum : NSObject {
    
}
+(BOOL)isArrayType:(locTypeEnum)locType; 

@end
