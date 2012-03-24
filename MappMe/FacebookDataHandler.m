//
//  FacebookDataHandler.m
//  MappMe
//
//  Created by Parker Spielman on 3/23/12.
//  Copyright (c) 2012 Painted Ostrich. All rights reserved.
//

#import "FacebookDataHandler.h"
#import "LocationTypeEnum.h"
#import "SBJSON.h"
#import "MappMeAppDelegate.h"
#import "DebugLog.h"

@implementation FacebookDataHandler{
    NSMutableDictionary *schoolTypeMapping;
}


#pragma mark - Custom Facebook Server communication methods
- (NSString *)doGraphGetWithUrlString:(NSString *)url_string {
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url_string]];
	
    NSString * returnString;
	NSError *err;
	NSURLResponse *resp;
	NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
	
	if (resp != nil) {
        returnString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
		
	} else if (err != nil) {
		DebugLog(@"error", err);
    }
	
	return returnString;
	
}
- (NSDictionary *)doMultiQuery:(NSString *)action {	
    MappMeAppDelegate* delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString * accessToken = (NSString *)[[delegate facebook] accessToken];
    NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/fql?q=%@", action];
	
    /**********String Format *****************/
    /*$fql_multiquery_url = 'https://graph.facebook.com/'
     . 'fql?q={"all+friends":"SELECT+uid2+FROM+friend+WHERE+uid1=me()",'
     . '"my+name":"SELECT+name+FROM+user+WHERE+uid=me()"}'
     . '&' . $access_token;
     */
    
	if (accessToken != nil) {
		//now that any variables have been appended, let's attach the access token....
		url_string = [NSString stringWithFormat:@"%@&access_token=%@", url_string, accessToken];
	}
	//encode the string
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"URL STRING: %@", url_string);
    url_string = [self doGraphGetWithUrlString:url_string];
    SBJSON *parser = [[SBJSON alloc] init];
	NSDictionary *parsed_json = [parser objectWithString:url_string error:nil];	
    //Data encapsulates request
	NSDictionary *data = (NSDictionary *)[parsed_json objectForKey:@"data"];
    return data;
}

#pragma mark - parsing methods for data processing
-(void)parseFbFriends:(NSDictionary*)bas_info andCityType:(NSString*)locTypeString{
    
    /*LocType used to keep track of which city info from Facebook is being received*/
    locTypeEnum locType = tLocationTypeCount;
    if ([locTypeString isEqualToString:@"current_location"]){
        locType = tCurrentLocation;
    } 
    if ([locTypeString isEqualToString:@"hometown_location"]){
        locType = tHomeTown;
    }
    if (locType != tHomeTown && locType != tCurrentLocation &&![locTypeString isEqualToString:@"education"] ){
        DebugLog(@"Warning: locType set incorrectly");
    }
    MappMeAppDelegate* delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *friendsTemp;
    NSDictionary *friends = [bas_info objectForKey:@"fql_result_set"];
    NSEnumerator *friendsEnum = [friends objectEnumerator];
    while ((friendsTemp = (NSDictionary *)[friendsEnum nextObject])) {
        if([[friendsTemp objectForKey:locTypeString]count]==0){
            //If empty entry for location, continue
            continue;
        }
        NSString * uid = (NSString*)[friendsTemp objectForKey:@"uid"];
        NSString * town_id = [[friendsTemp objectForKey:locTypeString]objectForKey:@"id"];
        NSString * town_name = [[friendsTemp objectForKey:locTypeString]objectForKey:@"name"];
        NSString *name = [friendsTemp objectForKey:@"name"];
        
        [delegate.placeIdMapping addId:town_id andPlace:town_name];
        [delegate.peopleContainer setPersonPlaceInContainer:name personId:uid placeId:town_id andTypeId:locType];
    }
}
/* Location Queries From Facebook:  Adds an Dictionary of cities and facbeook ids to mapping*/
-(void)parseFbCity:(NSDictionary*)bas_info{
    MappMeAppDelegate* delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *citiesTemp;
    NSDictionary *coords = [bas_info objectForKey:@"fql_result_set"];
    NSEnumerator *citiesEnum = [coords objectEnumerator];
    while ((citiesTemp = [citiesEnum nextObject])) {
        NSDictionary *loc= [citiesTemp objectForKey:@"location"];
        
        /*Make sure location array is not empty*/
        if ([loc respondsToSelector:@selector(objectForKey:)]) {
            [[delegate placeIdMapping]addCoordsLat:[loc objectForKey:@"latitude"] andLong:[loc objectForKey:@"longitude"] forPlaceId:[citiesTemp objectForKey:@"page_id"]];
        }
        else{
            NSString * page_id = [citiesTemp objectForKey:@"page_id"];
            DebugLog(@"%@ not found; id: %@",[delegate.placeIdMapping getPlaceFromId:page_id],page_id);
        }
    }
}
-(void)parseFbEdu:(NSDictionary*)bas_info{
    MappMeAppDelegate* delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *schoolTemp;
    NSEnumerator *schoolLocEnum = [[bas_info objectForKey:@"fql_result_set"] objectEnumerator];
    while ((schoolTemp = [schoolLocEnum nextObject])) {
        if ([(NSString *)[schoolTemp objectForKey:@"name"]length] >3){
            NSDictionary *loc= [schoolTemp objectForKey:@"location"];
            NSString * school_id = [schoolTemp objectForKey:@"page_id"];
            //If have lat and long
            if ([loc objectForKey:@"latitude"]){
                [[delegate placeIdMapping]addCoordsLat:[loc objectForKey:@"latitude"] andLong:[loc objectForKey:@"longitude"] forPlaceId:school_id];
            }else{
                NSString *type = [schoolTypeMapping objectForKey:school_id];
                [delegate.placeIdMapping doCoordLookupAndSet:school_id withDict:loc andTypeString:type];
            }
        }
        
    }
}
-(void)parseFbFriendsEdu:(NSDictionary*)bas_info{
    MappMeAppDelegate* delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *friendsTemp;
    NSDictionary *friendsEdu = [bas_info objectForKey:@"fql_result_set"];
    NSEnumerator *friendsEnum = [friendsEdu objectEnumerator];
    while ((friendsTemp = (NSDictionary *)[friendsEnum nextObject])) {
        if([[friendsTemp objectForKey:@"education"]count]==0){
            continue;
        }
        NSEnumerator *schoolsEnum = [[friendsTemp objectForKey:@"education"] objectEnumerator];
        NSDictionary *school;
        NSString * uid = [friendsTemp objectForKey:@"uid"];
        NSString * name = [friendsTemp objectForKey:@"name"];
        while (school = (NSDictionary*)[schoolsEnum nextObject]) {
            NSString * school_id = (NSString*)[[school objectForKey:@"school"]objectForKey:@"id"];
            NSString * school_name = (NSString*)[[school objectForKey:@"school"]objectForKey:@"name"];
            NSString * school_type = (NSString*)[school objectForKey:@"type"];
            locTypeEnum placeType = [LocationTypeEnum getEnumFromName:school_type];
            //                    DebugLog(@"%@ -  %@, %@", school_name, school_type, school_id);
            [schoolTypeMapping setObject:school_type forKey:school_id];
            [delegate.placeIdMapping addId:school_id andPlace:school_name];
            [delegate.peopleContainer setPersonPlaceInContainer:name personId:uid placeId:school_id andTypeId:placeType];
        }
    }
}
-(void)parseFacebookInfoController: (NSDictionary *)infoArray andType:(NSString*)locTypeString{
    MappMeAppDelegate* delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
	NSEnumerator *enumerator = [infoArray objectEnumerator];
	NSDictionary *bas_info;

    /* Stores mapping temporarily between school_id and school_type
     Used to help location lookup on Google Maps
     Populated in friendsEdu section
     Used in schoolLocation.  Init here so can be used in multiple calls. should prbly architect better*/
    schoolTypeMapping = [[NSMutableDictionary alloc] init];

    while ((bas_info = (NSDictionary *)[enumerator nextObject])) {
        NSString * loc = [bas_info objectForKey:@"name"];
        /*Distribute Parsing to Specialized Methods*/
        if ([loc isEqualToString :@"friends"]){
            [self parseFbFriends:bas_info andCityType:locTypeString];
        }
        if ([loc isEqualToString:@"friendsEdu"]){
            [self parseFbFriendsEdu:bas_info];
        }
        if ([loc isEqualToString:@"location"]){
            [self parseFbCity:bas_info];
        }
        if ([loc isEqualToString:@"schoolLocation"]){
            [self parseFbEdu:bas_info];
        }
    }
    
    DebugLog(@"Number of friends %i", [delegate.peopleContainer getNumPeople]);
    DebugLog(@"Number of cities %i",[delegate.placeIdMapping getNumPlaces]);
    
//    [delegate.peopleContainer printGroupings:tHomeTown];
//    [delegate.peopleContainer printGroupings:tCurrentLocation];
}

#pragma mark - Query String Facebook Data Retrieval Methods
-(void)getCurrentLocation{
    
    NSString* fql1 = [NSString stringWithFormat:
                      @"SELECT name,uid, current_location.name, current_location.id FROM user WHERE  uid IN (SELECT uid2 FROM friend WHERE uid1= me()) AND current_location>0 ORDER BY current_location DESC"];
    
    NSString* fql2 = [NSString stringWithFormat:
                      @"SELECT location.latitude,location.longitude,page_id FROM page WHERE page_id IN (SELECT current_location FROM #friends)"];
    NSString* fqlC = [NSString stringWithFormat:
                      @"{\"friends\":\"%@\",\"location\":\"%@\"}",fql1,fql2];
    NSDictionary *response = [self doMultiQuery:fqlC];  
    [self parseFacebookInfoController:response andType:@"current_location"];
    
}
-(void)getHometownLocation{
    
    NSString* fqlH1 = [NSString stringWithFormat:
                       @"SELECT name,uid, hometown_location.name, hometown_location.id FROM user WHERE  uid IN (SELECT uid2 FROM friend WHERE uid1= me()) AND hometown_location>0 ORDER BY hometown_location DESC "];
    
    NSString* fqlH2 = [NSString stringWithFormat:
                       @"SELECT location.latitude,location.longitude,name,page_id FROM page WHERE page_id IN (SELECT hometown_location FROM #friends)"];
    NSString* fqlH = [NSString stringWithFormat:
                      @"{\"friends\":\"%@\",\"location\":\"%@\"}",fqlH1,fqlH2];
    NSDictionary *response = [self doMultiQuery:fqlH];  
    [self parseFacebookInfoController:response andType:@"hometown_location"];    
    
}
-(void)getEducationInfo{
    NSString* fqlE1 = [NSString stringWithFormat:
                       @"SELECT name, uid, education FROM user WHERE  uid IN (SELECT uid2 FROM friend WHERE uid1= me())"];
    NSString* fqlE2 = [NSString stringWithFormat:
                       @"SELECT location,name,page_id FROM page WHERE page_id IN (SELECT education FROM #friendsEdu)"];
    NSString* fqlE = [NSString stringWithFormat:
                      @"{\"friendsEdu\":\"%@\",\"schoolLocation\":\"%@\"}",fqlE1,fqlE2];
    NSDictionary *response = [self doMultiQuery:fqlE];  
    [self parseFacebookInfoController:response andType:@"education"];  
}


@end
