//
//  MyAnnotation.h
//  SimpleMapView

//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "LocationTypeEnum.h"

@class Place;
@interface MyAnnotation : NSObject<MKAnnotation> {
    
	CLLocationCoordinate2D	coordinate;
	NSString*				title;
	NSString*				subtitle;
    //Will only be set if there is only one person associated with this MKAnnotation.
    NSString*               person_id;
    //An array of all the people under this annotation object.
    NSArray*                peopleArr;
}

@property (nonatomic, assign)	CLLocationCoordinate2D	coordinate;
@property (nonatomic, copy)		NSString*				title;
@property (nonatomic, copy)		NSString*				subtitle;
@property (nonatomic, copy)		NSString*				person_id;
@property (nonatomic, retain)   NSArray*				peopleArr;

-(MyAnnotation*) initWithPlace:(Place*)place forLocType:(locTypeEnum)locType;

@end