//
//  MyAnnotation.h
//  SimpleMapView

//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Friend.h"

@interface MyAnnotation : NSObject<MKAnnotation> {
    
	CLLocationCoordinate2D	coordinate;
	NSString*				title;
	NSString*				subtitle;
	int				type;
}

@property (nonatomic, assign)	CLLocationCoordinate2D	coordinate;
@property (nonatomic, copy)		NSString*				title;
@property (nonatomic, copy)		NSString*				subtitle;
@property (nonatomic)		     int				    type;

+(NSArray*)makeAnnotationFromDict:(NSDictionary*)groupings;
+(NSArray*)getLocationsForFriend:(Friend *)friend;

@end