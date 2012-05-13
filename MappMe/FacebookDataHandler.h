//
//  FacebookDataHandler.h
//  MappMe
//
//  Created by Parker Spielman on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DataProgressController;
/*Class handles communication with Facebook Server for Data and Processes Returned Info*/
@interface FacebookDataHandler : NSObject

+ (id)sharedInstance;
-(void)getCurrentLocation;
-(void)getHometownLocation;
-(void)getEducationInfo;
-(void)getMutualFriends:(NSString*)friendId;
//Get user permissions for our app.
- (void)getUserPermissions;

//Called when the app is becoming inactive(going to background)
//It will stop all outgoing nsoperations.
-(void) haltOperations;
-(void) resumeOperations;
-(void) cancelAllOperations;
@end
