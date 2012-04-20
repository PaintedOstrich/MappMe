//
//  MyAnnotation.m
//  SimpleMapView
//

//

#import "MyAnnotation.h"
#import "Place.h"
#import "LocationTypeEnum.h"

@implementation MyAnnotation

@synthesize title, subtitle, coordinate, person_id, peopleArr, locType;

-(MyAnnotation*) initWithPlace:(Place *)place forLocType:(locTypeEnum)type
{
    if(self = [super init]){
        self.title = place.name;
        self.coordinate = place.location;
        self.peopleArr = [[place getPeople:type] allObjects];
        [self countDependentConfigs:self.peopleArr];
        self.locType = type;
    }
    return self;
}

-(MyAnnotation*) initWithPlace:(Place *)place forPerson:(Person*)person forLocType:(locTypeEnum)type
{
    if(self = [super init]){
        self.title = place.name;
        self.coordinate = place.location;
        self.subtitle = [LocationTypeEnum getNameFromEnum:type];
        self.locType = type;
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
    }
    else {
        self.subtitle=[[NSString alloc] initWithFormat:@"%d%@",count,@" friends"];	
    }
}

@end