//
//  MyAnnotation.m
//  SimpleMapView
//

//

#import "MyAnnotation.h"
#import "Place.h"
#import "LocationTypeEnum.h"

@implementation MyAnnotation

@synthesize title, subtitle, coordinate, person_id, peopleArr, locType, placeHolderImg, place_id;


-(MyAnnotation*) initWithPlace:(Place *)place forLocType:(locTypeEnum)type
{
    if(self = [super init]){
        self.title = place.name;
        self.coordinate = place.location;
        self.peopleArr = [[place getPeople:type] allObjects];
        [self countDependentConfigs:self.peopleArr];
        self.locType = type;
        self.place_id = place.uid;
    }
    return self;
}
//Returns all people from place
-(MyAnnotation*) initWithPlace:(Place*)place{
     if(self = [super init]){
        self.title = [[NSString alloc] initWithFormat:@"Friends from %@",place.name];
        self.coordinate = place.location;
        NSMutableSet *people = [[NSMutableSet alloc] init];
        for (int i =0; i< tLocationTypeCount; i++){
            [people addObjectsFromArray:[[place getPeople:i] allObjects]];
        }
        self.peopleArr = [people allObjects];
        [self countDependentConfigs:self.peopleArr];
        self.locType = 0;
        self.place_id = place.uid;
     }
    return self;
}
//Method only returns friends with the specified individual. This used when showing mututal friends
-(MyAnnotation*) initWithPlace:(Place *)place forLocType:(locTypeEnum)type forMutualFriend:(Person*)friendsWith
{
    if(self = [super init]){
        self.title = place.name;
        NSArray*allPeople = [[place getPeople:type] allObjects];
        NSMutableArray *mutualPeople = [[NSMutableArray alloc] init];
        NSEnumerator *friendEnum = [allPeople objectEnumerator];
        Person *friend;
        while (friend = (Person*)[friendEnum nextObject]) {
            if ([friendsWith.mutualFriends indexOfObject:friend.uid]!=NSNotFound) {
                [mutualPeople addObject:friend];
                DebugLog(@"%@",friend);
            }
        }        
        self.peopleArr = mutualPeople;
        self.coordinate = place.location;
        [self countDependentConfigs:self.peopleArr];
        self.locType = type;
        self.place_id = place.uid;
    }
    //DebugLog(@"%i, people array :\n%@",[self.peopleArr count]);
    return self;
}

//For item when MAPP ing  friend
-(MyAnnotation*) initWithPlace:(Place *)place forPerson:(Person*)person forLocType:(locTypeEnum)type
{
    if(self = [super init]){
        self.place_id = place.uid;
        self.title = place.name;
        self.coordinate = place.location;
        self.subtitle = [LocationTypeEnum getNameFromEnum:type];
        self.locType = type;
        self.placeHolderImg = @"profile.png";
    }
    return self;
}

//Some configuration such as subtitle and person_id is dependent on 
// the number of people associated with this place.
//We do this configuration in this method.
-(void) countDependentConfigs:(NSArray*)arr
{
    int count = [arr count];
    
    if(count == 1){
        Person* person = [arr objectAtIndex:0];
        self.subtitle=person.name;
        self.person_id = person.uid;
        self.placeHolderImg = @"profile.png";
    }
    else {
        self.subtitle=[[NSString alloc] initWithFormat:@"%d%@",count,@" friends"];
        self.placeHolderImg = @"group.png";
    }
}

-(BOOL)hasValidCoordinate
{
    //For now I know (0, 0) is not a valid coordinate. 
    //I could not find the valid range of latitude and logitude.
    if (self.coordinate.latitude == 0 && self.coordinate.longitude == 0){
        return FALSE;
    }
    return TRUE;
}

@end