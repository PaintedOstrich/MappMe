//
//  AbstractContainer.h
//  MappMe
//
//  Created by Di Peng on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AbstractContainer : NSObject {
    NSMutableDictionary* _data;
}

//Clear all data in this container.
-(void) clearData;
-(int)count;
-(NSArray*) allValues;

@end
