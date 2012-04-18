#import <GHUnitIOS/GHUnit.h> 
#import "PeopleContainer.h"

@interface PeopleContainerTest: GHTestCase { }
@end

@implementation PeopleContainerTest

// Run before each test method
- (void)setUp { }

- (void) testAddPerson {
    NSString* string1 = @"hi";
    GHAssertNotNULL(string1, nil);
}

// Run after each test method
- (void)tearDown { }

@end

