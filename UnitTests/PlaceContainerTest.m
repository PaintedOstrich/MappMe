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

- (void) testGetPlacesUsedAs {
    Place* place1 = [places get:@"1" ];
    Place* place2 = [places get:@"2" ];
    
    Person* person1 = [[Person alloc] initPerson:@"1" withName:@"Person1"];
    Person* person2 = [[Person alloc] initPerson:@"2" withName:@"Person2"];
    
    [place1 addPerson:person1 forType:tHomeTown];
    [place1 addPerson:person2 forType:tHighSchool];
    [place2 addPerson:person1 forType:tHighSchool];
    
    NSArray* homeTowns = [places getPlacesUsedAs:tHomeTown];
    GHAssertTrue([homeTowns count] == 1, @"Only place1 is used as tHomeTown");
    GHAssertEquals(place1, [homeTowns objectAtIndex:0], nil);
    
    NSArray* highschools = [places getPlacesUsedAs:tHighSchool];
    GHAssertTrue([highschools count] == 2, @"2 places are used as tHighShcool");
    
    NSArray* graduateShcools = [places getPlacesUsedAs:tGradSchool];
    GHAssertTrue([graduateShcools count] == 0, @"no places are used as tGraduateSchool");
}

// Run after each test method
- (void)tearDown {
    places = nil;
}

@end

