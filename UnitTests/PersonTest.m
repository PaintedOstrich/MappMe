#import <GHUnitIOS/GHUnit.h> 
#import "Person.h"
#import "Place.h"

@interface PersonTest: GHTestCase { }
@end

@implementation PersonTest {
    Person* person;
}

// Run before each test method
- (void)setUp { 
  person = [[Person alloc] initPerson:@"MyId" withName:@"MyName"];
}

- (void) testInitPerson {
    GHAssertEqualStrings(@"MyId", person.uid,nil);
    GHAssertEqualStrings(@"MyName", person.name,nil);
    GHAssertEqualStrings(@"https://graph.facebook.com/MyId/picture?type=square", person.profileUrl, nil);
    GHAssertTrue(0 == [person.colleges count], @"No object in colleges array");
}

-(void) testAddPlace {
    Place* dummyPlace = [[Place alloc] initPlace:@"MyPlaceId" withName:@"MyPlace"];
    [person addPlace:dummyPlace withType:tHomeTown];
    GHAssertEquals(dummyPlace, person.hometown, nil);
    
    [person addPlace:dummyPlace withType:tHighSchool];
    GHAssertTrue([person.highschools containsObject:dummyPlace], @"Already has the place in highschools set");
}

// Run after each test method
- (void)tearDown { }

@end
