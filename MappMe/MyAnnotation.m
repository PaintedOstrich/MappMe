//
//  MyAnnotation.m
//  SimpleMapView
//

//

#import "MyAnnotation.h"
#import "Place.h"
#import "MappMeAppDelegate.h"
#import "DebugLog.h"
#import "LocationTypeEnum.h"

@implementation MyAnnotation

@synthesize title;
@synthesize subtitle;
@synthesize coordinate;
@synthesize type;


/*Returns an array of annotations, grouping all friends per place into annotation
  @param:  dictionary of keys:city id with values: array of friend Id's
 */
+(NSArray*)makeAnnotationFromDict:(NSDictionary*)groupings{
    MappMeAppDelegate *delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:[groupings count]];
    NSArray *keys = [groupings allKeys];
    int i, count;
    count = [keys count];
    for (i = 0; i < count; i++)
    {
        NSString * placeId = [keys objectAtIndex: i];
        Place *loc = [delegate.mainDataManager.placeContainer getPlaceFromId:placeId];
        if (!loc) {
            //If this location is Null
            DebugLog(@"%@ does not have location",[delegate.mainDataManager.placeContainer getPlaceNameFromId:placeId]);
            continue;
        }
        MyAnnotation* annotationItem=[[MyAnnotation alloc] init];
        annotationItem.coordinate=loc.location;
        if (annotationItem.coordinate.longitude == 0) {
            DebugLog(@"not showing null location : %@", [delegate.mainDataManager.placeContainer getPlaceNameFromId:placeId]);
            continue;
        }
        annotationItem.title=[delegate.mainDataManager.placeContainer getPlaceNameFromId:placeId];
        NSSet * groupPerPlace = (NSSet*)[groupings objectForKey: placeId];
        if([groupPerPlace count]==1){
            NSString *fId= [groupPerPlace anyObject];
            NSString *fName=[delegate.mainDataManager.peopleContainer getNameFromId:fId];
            annotationItem.subtitle=fName;
        }
        else {
            annotationItem.subtitle=[[NSString alloc] initWithFormat:@"%d%@",[groupPerPlace count],@" friends"];	
        }
        //Add in type of Annotation depends on num of friends
        //the bigger the number, more people at that location
        if([groupPerPlace count]>25){
            annotationItem.type=tTwentyFive;
        }
        else if([groupPerPlace count]>15){
            annotationItem.type=tFifteen;
        }
        else if([groupPerPlace count]>10){
            annotationItem.type=tTen;
        }
        else if([groupPerPlace count]>5){
            annotationItem.type=tFive;
        }
        else if([groupPerPlace count]>3){
            annotationItem.type=tThree;
        }
        else if([groupPerPlace count]>2){
            annotationItem.type=tTwo;
        }
        else{
            annotationItem.type=tOne;
        }
        [annotations addObject:annotationItem];
    }
    return (NSArray*)annotations;
}

/*Returns an array of annotations, Where each annotation is for a location coordinate of the friend
 @param:  Friend instance
 */
+(NSArray*)getLocationsForFriend:(Friend *)friend{  
    MappMeAppDelegate *delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray* annotations = [[NSMutableArray alloc]initWithCapacity:10];
    for (int type =0; type<tLocationTypeCount; type++){
        locTypeEnum locType = type;
        /*If only one value per field */
        if (![LocationTypeEnum isArrayType:locType]){
            DebugLog(@"%@",friend);
            if([friend hasEntryForType:locType]){
                MyAnnotation* annotationItem=[[MyAnnotation alloc] init];
                NSString *placeId = [friend getStringEntryForLocType:locType];
                Place *loc = [delegate.mainDataManager.placeContainer getPlaceFromId:placeId];
                annotationItem.coordinate=loc.location;
                annotationItem.type=locType;
                annotationItem.subtitle = [LocationTypeEnum getNameFromEnum:locType];
                annotationItem.title = [delegate.mainDataManager.placeContainer getPlaceNameFromId:placeId];
                [annotations addObject:annotationItem];
            }
        } /*Dealing with Array of possible Values */
        else{
            if([friend hasEntryForType:locType]){
                NSEnumerator *itemEnum = [[friend getArrayEntryForLocType:locType]objectEnumerator];
                NSString *placeId;
                while (placeId = [itemEnum nextObject]) {
                    Place *loc = [delegate.mainDataManager.placeContainer getPlaceFromId:placeId];
                    /*Checks for Valid Coordinate (not valid if not found from Google Lookup)*/
                    if (loc){
                        MyAnnotation* annotationItem=[[MyAnnotation alloc] init];
                        annotationItem.coordinate=loc.location;
                        annotationItem.type=locType;
                        annotationItem.subtitle = [LocationTypeEnum getNameFromEnum:locType];
                        annotationItem.title = [delegate.mainDataManager.placeContainer getPlaceNameFromId:placeId];
                        [annotations addObject:annotationItem];
                    }
                }
            }    
        }
        
    }
    return (NSArray*)annotations;
}
//Returns Appropriate Image for Pin,given type and displayType(location for all friends, or location element of friend)
+(UIImage*)getPinImage:(int)type isFriendLocationType:(BOOL)isFriendType{
    //If we're showing all location types for a friend
    UIImage *returnImage;
    if(!isFriendType){
        //Switch based upon enum values set in above makeAnnotationFromDict
        switch (type) {
            case tTwentyFive:
                returnImage=[UIImage imageNamed:@"redPin.png"];
                break;  
            case tFifteen:
                returnImage=[UIImage imageNamed:@"orangePin.png"];
                break;  
            case tTen:
                returnImage=[UIImage imageNamed:@"yellowPin.png"];
                break; 
            case tFive:
                returnImage=[UIImage imageNamed:@"yellow-greenPin.png"];
                break;  
            case tThree:
                returnImage=[UIImage imageNamed:@"greenPin.png"];
                break;  
            case tTwo:
                returnImage=[UIImage imageNamed:@"tealPin.png"];
                break;
            case tOne:
                returnImage=[UIImage imageNamed:@"bluePin.png"];
                break;  
            default:
                DebugLog(@"Warning: Default Case Reached");
                break;
        }
    }
    //If we're showing a location criteria such as current location for all friends
    else{
        switch (type) {
            case tCurrentLocation:
                returnImage=[UIImage imageNamed:@"bluePin1.25.png"];
                break;
            case tHomeTown:
                returnImage=[UIImage imageNamed:@"bluePin1.25.png"];
                break;  
            case tHighSchool:
                returnImage=[UIImage imageNamed:@"bluePin1.25.png"];
                break;  
            case tCollege:
                returnImage=[UIImage imageNamed:@"bluePin1.25.png"];
                break; 
            case tGradSchool:
                returnImage=[UIImage imageNamed:@"bluePin1.25.png"];
                break;  
            case tWork:
                returnImage=[UIImage imageNamed:@"bluePin1.25.png"];
                break;  
            default:
                DebugLog(@"Warning: Default Case Reached");
                break;
        }
    }
    return returnImage;
}
@end