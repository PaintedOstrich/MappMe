//
//  AbstractContainer.m
//  MappMe
//
//  Created by Di Peng on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AbstractContainer.h"

@implementation AbstractContainer

-(id)init{
    if(self = [super init]){
        _data = [[NSMutableDictionary alloc] initWithCapacity:20];
    }
    return self;
}

-(int)count
{
    return [_data count];
}

-(NSArray*) allValues
{
    return [_data allValues];
}

-(void) clearData
{
    [_data removeAllObjects];
}

@end
