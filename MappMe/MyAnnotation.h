//
//  MyAnnotation.h
//  SimpleMapView

//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "LocationTypeEnum.h"

@class Place;
@class Person;
@interface MyAnnotation : NSObject<MKAnnotation> {
    
	CLLocationCoordinate2D	coordinate;
	NSString*				title;
	NSString*				subtitle;
    NSString*               place_id;
    //Will only be set if there is only one person associated with this MKAnnotation.
    NSString*               person_id;
    //An array of all the people under this annotation object.
    NSArray*                peopleArr;
    //Name of the place holder image
    NSString*               placeHolderImg;
    locTypeEnum             locType;
}

@property (nonatomic, assign)	CLLocationCoordinate2D	coordinate;
@property (nonatomic, copy)		NSString*				title;
@property (nonatomic, copy)		NSString*				subtitle;
@property (nonatomic, copy)		NSString*				person_id;
@property (nonatomic, copy)		NSString*				place_id;
@property (nonatomic, copy)		NSString*				placeHolderImg;
@property (nonatomic, retain)   NSArray*				peopleArr;
@property locTypeEnum locType;

-(MyAnnotation*) initWithPlace:(Place*)place forLocType:(locTypeEnum)locType;
-(MyAnnotation*) initWithPlace:(Place *)place forPerson:(Person*)person forLocType:(locTypeEnum)type;
-(MyAnnotation*) initWithPlace:(Place *)place forLocType:(locTypeEnum)type forMutualFriend:(Person*)friendsWith;
//Sometimes we did not add coordinate for this place (0,0) by default.
//Or there may be other cases that we will encounter invalid coordinate.
//We want to be able to detect them in this same method and simply return true only when the coordinate is 
//valid.
-(BOOL)hasValidCoordinate;
@end