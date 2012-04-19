//
//  PeopleContainer.h
//  MappMe
//
//  Created by Parker Spielman on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationTypeEnum.h"
#import "Person.h"

@interface PeopleContainer : NSObject{

}

-(Person*)get:(NSString*)person_id;
-(int)count;
-(NSArray*)allValues;

@end
