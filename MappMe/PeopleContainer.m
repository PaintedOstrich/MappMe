//
//  PeopleContainer.m
//  MappMe
//
//  Created by Parker Spielman on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PeopleContainer.h"
#import "MappMeAppDelegate.h"
#import "DebugLog.h"
#import "DataManagerSingleton.h"

@implementation PeopleContainer{
    NSMutableDictionary* _data;
}

-(id)init{
    if(self = [super init]){
        _data = [[NSMutableDictionary alloc] initWithCapacity:20];
    }
    return self;
}

/*
 * Return a person object by id. 
 * If this id is not registered, will create a person object with name "No Name" and return it.
 */
-(Person*)get:(NSString*)person_id
{
    Person* person = [_data objectForKey:person_id];
    if (person == nil) {
        person = [[Person alloc] initPerson:person_id withName:@"No Name"];
        [_data setValue:person forKey:person_id];
    }
    return person;
}

/*
 * Return total number of people maintained in PeopleContainer.
 */
-(int)count
{
    return [_data count];
}

-(NSArray*) allValues
{
    return [_data allValues];
}

@end
