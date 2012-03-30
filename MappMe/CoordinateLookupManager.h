//
//  CoordinateLookupManager.h
//  MappMe
//
//  Created by Parker Spielman on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CoordPairsHelper.h"

@interface CoordinateLookupManager : NSObject

+(CoordPairsHelper *)manageCoordLookupForPlace:(NSString *)lookupString;
+(CoordPairsHelper *)manageCoordLookupForEdu:(NSString *)placeName withSupInfo:(NSDictionary*)supInfo 
                         andTypeString:(NSString *)schoolType;
@end