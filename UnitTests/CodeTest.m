//
//  CodeTest.m
//  MappMe
//
//  Created by Codier
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <GHUnitIOS/GHUnit.h> 

@interface CodeTest: GHTestCase { }
@end

//Sometimes we want to test how a certain method behaves (take isMemberOfClass for example)
//We can do it here.
@implementation CodeTest{
}

// Run before each test method
- (void)setUp {
    
}

-(void) testIsMemberOfOfClass {
    //  isKindOfClass: returns YES if the receiver is an instance of the specified class or an instance of any class that inherits from the specified class.
    //    
    //  isMemberOfClass: returns YES if the receiver is an instance of the specified class.
    //        
    //  Most of the time you want to use isKindOfClass: to ensure that your code also works with subclasses.
    
    NSArray* tmpArr = nil;
    BOOL answer = [tmpArr isMemberOfClass:[NSArray class]];
    GHAssertFalse(answer, @"nil is not an NSArray");
    
    tmpArr = [[NSMutableArray alloc] initWithCapacity:1];
    answer = [tmpArr isMemberOfClass:[NSArray class]];
    GHAssertFalse(answer, @"NSMutableArray is not an NSArray");
    answer = [tmpArr isKindOfClass:[NSArray class]];
    GHAssertTrue(answer, @"NSMutableArray is a kind of an NSArray");
    
    tmpArr = (NSArray*)[[NSDictionary alloc] init];
    answer = [tmpArr isKindOfClass:[NSArray class]];
    GHAssertFalse(answer, @"NSDictionary, although forcibly casted to NSArray, is still not NSArray");
    
    //Test to see if initing a dictionary with nil will have problems
    NSDictionary* tmpDic = [[NSDictionary alloc] initWithDictionary:nil];
    answer = [tmpDic isMemberOfClass:[NSDictionary class]];
    GHAssertFalse(answer, @"NSDictionary should never be init with nil!");
}

// Run after each test method
- (void)tearDown {
    
}

@end

