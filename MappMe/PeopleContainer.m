//
//  PeopleContainer.m
//  MappMe
//
//  Created by Parker Spielman on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PeopleContainer.h"

@implementation PeopleContainer

/*
 * Return a person object by id. 
 * If this id is not registered, will create a person object with name "No Name" and return it.
 */
-(Person*)get:(NSString*)person_id
{
    //We should never pass along nil as person_id
    if (person_id == nil) {
        [NSException raise:@"person_id is nil" format:@"person_id cannot be nil when calling get on PeopleContainer"];
    }

    Person* person = [_data objectForKey:person_id];
    if (person == nil) {
        person = [[Person alloc] initPerson:person_id withName:@"No Name"];
        [_data setValue:person forKey:person_id];
    }
    return person;
}
@end
