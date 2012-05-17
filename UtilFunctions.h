//
//  UtilFunctions.h
//  MappMe
//
//  Created by Parker Spielman on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UtilFunctions : NSObject

+(NSString *)convertToString:(id)object;
+(void) setBtnTitleForAllStates:(UIButton*)btn withText:(NSString*)txt;
@end
