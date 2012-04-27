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

//Test All Methods in Between
-(void) testConvertToString
{
    NSInteger * integer = (NSInteger*)123;
    // float floatNumber = 1.23;
    NSDecimalNumber* decNum = [[NSDecimalNumber alloc] initWithInt:123];
    NSString * string = @"123";
    
//    GHAssertEqualCStrings(string,[UtilFunctions convertToString:string], nil);
//    GHAssertEqualCStrings(string,[UtilFunctions convertToString:decNum], nil);
//    GHAssertEqualCStrings(string,[UtilFunctions convertToString:integer], nil);
    
}


// Run after each test method
- (void)tearDown {
    
}

@end

