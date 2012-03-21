//
//  FacebookImageHandler.h
//  MappMe
//
//  Created by Parker Spielman on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookImageHandler : NSObject

-(UIImage*) getProfPicFromId:(NSString *)uid;
@end
