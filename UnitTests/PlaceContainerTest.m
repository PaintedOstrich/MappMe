#import <GHUnitIOS/GHUnit.h> 
#import "PlaceContainer.h"

@interface PlaceContainerTest: GHTestCase { }
@end

@implementation PlaceContainerTest{
    PlaceContainer* places;
}

// Run before each test method
- (void)setUp {
    places = [[PlaceContainer alloc] init];
}

- (void) testGet {
    Place* place = [places get:@"123"];
    GHAssertEquals(place, [places get:@"123"], nil);
    GHAssertEquals(@"No Name", place.name, nil);
}

- (void) testUpdate {
    GHAssertTrue(0 == [places count], @"Start with 0 places");
    
    Place* place = [places update:@"234" withName:@"MyPlace"];
    GHAssertEquals(place, [places get:@"234"], nil);
    
    [places update:@"234" withName:@"MyNewPlace"];
    GHAssertEquals(@"MyNewPlace", place.name, nil);
    
    GHAssertTrue(1 == [places count], @"still only has 1 places");
}

// Run after each test method
- (void)tearDown {
    places = nil;
}

@end

