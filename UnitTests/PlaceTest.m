#import <GHUnitIOS/GHUnit.h> 
#import "Place.h"

@interface PlaceTest: GHTestCase { }
@end

@implementation PlaceTest {
    Place* place;
}

// Run before each test method
- (void)setUp { 
  place = [[Place alloc ]initPlace:@"MyPlaceId" withName:@"MyPlace"];
}

- (void) testInitPlace {
    GHAssertEqualStrings(@"MyPlaceId", place.uid,nil);
    GHAssertEqualStrings(@"MyPlace", place.name,nil);
}

-(void) testGetPeople {
    NSMutableSet* homeArr = [place getPeople:tHomeTown];
    NSMutableSet* homeArr2 = [place getPeople:tHomeTown];
    GHAssertEquals(homeArr, homeArr2, nil);
    GHAssertTrue([homeArr count] == 0, @"Array initially empty");
    
    NSMutableSet* collegesArr = [place getPeople:tCollege];
    GHAssertNotEquals(collegesArr, homeArr2, nil);
}

-(void) testAddPerson {
    Person* person = [[Person alloc] initPerson:@"123" withName:@"PName"];
    [place addPerson:person forType:tHomeTown];
    GHAssertTrue([[place getPeople:tHomeTown] count] == 1, @"tHomeTown set has one person");
    GHAssertTrue([[place getPeople:tHomeTown] containsObject:person], @"tHomeTown set contains the person");
    
    [place addPerson:person forType:tHomeTown];
    GHAssertTrue([[place getPeople:tHomeTown] count] == 1, @"adding same person twice will not affect total count");
}

-(void) testGetFullAddress {
    GHAssertEqualStrings(@"MyPlace", [place getFullAddress],nil);
    NSMutableDictionary* metaData = [[NSMutableDictionary alloc] initWithCapacity:5];
    [metaData setValue:@"" forKey:@"city"];
    [metaData setValue:@"MO" forKey:@"state"];
    [place addMetaData:metaData];
    GHAssertEqualStrings(@"MyPlace  MO", [place getFullAddress],nil);
}

// Run after each test method
- (void)tearDown { 
    place = nil;
}

@end

