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
#import "AbstractContainer.h"

@interface PeopleContainer : AbstractContainer

-(Person*)get:(NSString*)person_id;
@end
