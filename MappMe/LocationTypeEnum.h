//
//  LocationTypeEnum.h
//  MappMe
//
//  Created by Parker Spielman on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#define TODD   1

/*NOTE:  tLocationTypeCount used for iteration through enum with for Loop, 
         for (int i =0; i<tLocationTypeCount; i++)
 */
typedef enum locTypeEnum {
  //Represent when no loc type is selected.
  tNilLocType,
  tCurrentLocation,
  tHomeTown,
  tHighSchool,
  tCollege,
  tGradSchool,
  tWork,
  tLocationTypeCount
} locTypeEnum;

@interface LocationTypeEnum : NSObject {
    
}
//Tells whether content is string (FALSE) or array (TRUE)
+(BOOL)isArrayType:(locTypeEnum)locType; 

+(NSString *)getNameFromEnum:(locTypeEnum)locType;
+(locTypeEnum)getEnumFromName:(NSString *)placeName;
@end

