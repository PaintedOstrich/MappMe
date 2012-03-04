//
//  CoordinateLookupManager.h
//  MappMe
//
//  Created by Parker Spielman on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoordPairs.h"

@interface CoordinateLookupManager : NSObject

+(CoordPairs *)manageCoordLookupForPlace:(NSString *)lookupString;
+(CoordPairs *)manageCoordLookupForEdu:(NSString *)placeName withSupInfo:(NSDictionary*)supInfo 
                         andTypeString:(NSString *)schoolType;
@end
