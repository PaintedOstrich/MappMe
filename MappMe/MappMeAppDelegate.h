
#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import <dispatch/dispatch.h>

@interface MappMeAppDelegate : NSObject <UIApplicationDelegate>{
    Facebook *facebook;
    dispatch_queue_t backgroundQueue;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) Facebook *facebook;

@property (nonatomic)  dispatch_queue_t backgroundQueue;

@end
