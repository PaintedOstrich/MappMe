//
//  UtilFunctionsTest.m
//  MappMe
//
//  Created by Parker Spielman on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <GHUnitIOS/GHUnit.h> 
#import "UtilFunctions.h"

@interface UtilFunctionTest: GHTestCase { }
@end

@implementation UtilFunctionTest{
}

// Run before each test method
- (void)setUp {
    
}

-(void) testConvertToString {
    NSString* answer;
    
    answer = [UtilFunctions convertToString:@"Already is a string"];
    GHAssertEqualStrings(answer, @"Already is a string", nil);
}

-(void) testHasLoactionData {
    NSNumber* num = [[NSNumber alloc] initWithFloat:33.3f];
    NSDictionary* hasLocData = [[NSDictionary alloc] 
                               initWithObjectsAndKeys: @"", @"street", 
                                                       num, @"latitude", nil];
    NSDictionary* noLocData = [[NSDictionary alloc] 
                                initWithObjectsAndKeys: @"", @"street", 
                                                       @"", @"latitude", nil];
    
    BOOL answer;
    answer = [UtilFunctions hasLoactionData:hasLocData];
    GHAssertTrue(answer,@"It does have some location data");
    
    answer = [UtilFunctions hasLoactionData:noLocData];
    GHAssertFalse(answer,@"It does not have any location data");
}

// Run after each test method
- (void)tearDown {
    
}

@end

