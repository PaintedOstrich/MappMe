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
@property (nonatomic)		    NSString*				user_id;

+(NSArray*)makeAnnotationFromDict:(NSDictionary*)groupings;
+(NSArray*)getLocationsForFriend:(Friend *)friend;
+(UIImage*)getPinImage:(int)type isFriendLocationType:(BOOL)isFriendType;
@end