#import <GHUnitIOS/GHUnit.h> 
#import "Place.h"

@interface PlaceTest: GHTestCase { }
@end

@implementation PlaceTest {
    Place* place;
}

// Run before each test method
- (void)setUp { }

- (void) testInitPlace {
    place = [[Place alloc ]initPlace:@"MyPlaceId" withName:@"MyPlace"];
    GHAssertEqualStrings(@"MyPlaceId", place.uid,nil);
    GHAssertEqualStrings(@"MyPlace", place.name,nil);
}

// Run after each test method
- (void)tearDown { }

@end

