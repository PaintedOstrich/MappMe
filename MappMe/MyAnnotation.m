//
//  MyAnnotation.m
//  SimpleMapView
//

//

#import "MyAnnotation.h"
#import "Place.h"

@implementation MyAnnotation

@synthesize title, subtitle, coordinate, person_id, peopleArr;

-(MyAnnotation*) initWithPlace:(Place *)place forLocType:(locTypeEnum)locType
{
    if(self = [super init]){
        self.title = place.name;
        self.coordinate = place.location;
        self.peopleArr = [[place getPeople:locType] allObjects];
        [self countDependentConfigs:self.peopleArr];
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







//
///*Returns an array of annotations, grouping all friends per place into annotation
//  @param:  dictionary of keys:city id with values: array of friend Id's
// */
//+(NSArray*)makeAnnotationFromDict:(NSDictionary*)groupings{
////    MappMeAppDelegate *delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
//    DataManagerSingleton * mainDataManager = [DataManagerSingleton sharedManager];
//    NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:[groupings count]];
//    NSArray *keys = [groupings allKeys];
//    int i, count;
//    count = [keys count];
//    for (i = 0; i < count; i++)
//    {
//        NSString * placeId = [keys objectAtIndex: i];
//        Place *loc = [mainDataManager.placeContainer getPlaceFromId:placeId];
//        if (!loc) {
//            //If this location is Null
//            DebugLog(@"%@ does not have location",[mainDataManager.placeContainer getPlaceNameFromId:placeId]);
//            continue;
//        }
//        MyAnnotation* annotationItem=[[MyAnnotation alloc] init];
//        annotationItem.coordinate=loc.location;
//        //DebugLog(@"place: %@\n long: %d",loc.placeName, annotationItem.coordinate.longitude);
//        if (annotationItem.coordinate.longitude == 0) {
//            DebugLog(@"not showing null location : %@", [mainDataManager.placeContainer getPlaceNameFromId:placeId]);
//            continue;
//        }
//        annotationItem.title=[mainDataManager.placeContainer getPlaceNameFromId:placeId];
//        NSSet * groupPerPlace = (NSSet*)[groupings objectForKey: placeId];
//        if([groupPerPlace count]==1){
//            NSString *fId= [groupPerPlace anyObject];
//            NSString *fName=[mainDataManager.peopleContainer getNameFromId:fId];
//            annotationItem.subtitle=fName;
//            annotationItem.user_id = fId;
//        }
//        else {
//            annotationItem.user_id = nil;
//            annotationItem.subtitle=[[NSString alloc] initWithFormat:@"%d%@",[groupPerPlace count],@" friends"];	
//        }
//        //Add in type of Annotation depends on num of friends
//        //the bigger the number, more people at that location
//        if([groupPerPlace count]>25){
//            annotationItem.type=tTwentyFive;
//        }
//        else if([groupPerPlace count]>15){
//            annotationItem.type=tFifteen;
//        }
//        else if([groupPerPlace count]>10){
//            annotationItem.type=tTen;
//        }
//        else if([groupPerPlace count]>5){
//            annotationItem.type=tFive;
//        }
//        else if([groupPerPlace count]>3){
//            annotationItem.type=tThree;
//        }
//        else if([groupPerPlace count]>2){
//            annotationItem.type=tTwo;
//        }
//        else{
//            annotationItem.type=tOne;
//        }
//        [annotations addObject:annotationItem];
//    }
//    return (NSArray*)annotations;
//}
//
///*Returns an array of annotations, Where each annotation is for a location coordinate of the friend
// @param:  Friend instance
// */
////FIXME PUT IN PLACE CONTAINER
//+(NSArray*)getLocationsForFriend:(Person *)friend{  
////    MappMeAppDelegate *delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
//    DataManagerSingleton * mainDataManager = [DataManagerSingleton sharedManager];
//    NSMutableArray* annotations = [[NSMutableArray alloc]initWithCapacity:10];
//  //  DebugLog(@"%@",friend);
//    for (int type =0; type<tLocationTypeCount; type++){
//        locTypeEnum locType = type;
//        /*If only one value per field */
//        if (![LocationTypeEnum isArrayType:locType]){
//
//            if([friend hasEntryForType:locType]){
//                MyAnnotation* annotationItem=[[MyAnnotation alloc] init];
//                NSString *placeId = [friend getStringEntryForLocType:locType];
//                Place *loc = [mainDataManager.placeContainer getPlaceFromId:placeId];
//                annotationItem.coordinate=loc.location;
//                annotationItem.type=locType;
//                annotationItem.subtitle = [LocationTypeEnum getNameFromEnum:locType];
//                annotationItem.title = [mainDataManager.placeContainer getPlaceNameFromId:placeId];
//                [annotations addObject:annotationItem];
//            }
//        } /*Dealing with Array of possible Values */
//        else{
//            if([friend hasEntryForType:locType]){
//                NSEnumerator *itemEnum = [[friend getArrayEntryForLocType:locType]objectEnumerator];
//                NSString *placeId;
//                while (placeId = [itemEnum nextObject]) {
//                    Place *loc = [mainDataManager.placeContainer getPlaceFromId:placeId];
//                    /*Checks for Valid Coordinate (not valid if not found from Google Lookup)*/
//                    if (loc){
//                        MyAnnotation* annotationItem=[[MyAnnotation alloc] init];
//                        annotationItem.coordinate=loc.location;
//                        annotationItem.type=locType;
//                        annotationItem.subtitle = [LocationTypeEnum getNameFromEnum:locType];
//                        annotationItem.title = [mainDataManager.placeContainer getPlaceNameFromId:placeId];
//                        [annotations addObject:annotationItem];
//                    }
//                }
//            }    
//        }
//        
//    }
//    return (NSArray*)annotations;
//}
////Returns Appropriate Image for Pin,given type and displayType(location for all friends, or location element of friend)
//+(UIImage*)getPinImage:(int)type isFriendLocationType:(BOOL)isFriendType{
//   //}
@end