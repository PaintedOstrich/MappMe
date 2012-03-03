//
//  MyAnnotation.h
//  SimpleMapView

//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject<MKAnnotation> {
    
	CLLocationCoordinate2D	coordinate;
	NSString*				title;
	NSString*				subtitle;
	int				type;
	//NSURL*                  url;
}

@property (nonatomic, assign)	CLLocationCoordinate2D	coordinate;
@property (nonatomic, copy)		NSString*				title;
@property (nonatomic, copy)		NSString*				subtitle;
@property (nonatomic)		     int				    type;
//@property (nonatomic, retain)   NSURL*                  url;
@end