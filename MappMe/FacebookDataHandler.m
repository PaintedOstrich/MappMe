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
#import "DataProgressUpdater.h"
#import "ASIHTTPRequest.h"

@interface FacebookDataHandler()
-(void)parseFacebookInfoController: (NSDictionary *)infoArray;
-(void)doAsynchGraphGetWithUrlString:(NSURL *)sourceURL;

@end
@implementation FacebookDataHandler{
    NSMutableDictionary *schoolTypeMapping;
    DataManagerSingleton * mainDataManager;
    DataProgressUpdater *dataProgressUpdater;
}

-(id)init{
    if(self = [super init]){
        mainDataManager = [DataManagerSingleton sharedManager];
        dataProgressUpdater = [[DataProgressUpdater alloc] init];
    }
    return self;
}
//sets progress updater delegate to be main controller, in this case
-(void)setProgressUpdaterDelegate:(id)delegate{
    [dataProgressUpdater setProgressUpdaterDelegate:delegate];
}
#pragma mark - Custom Facebook Server communication methods
//Asynchronous version of Graph Api Calls.  
-(void)asynchMultQueryHelper:(NSString*)action{
    MappMeAppDelegate* delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString * accessToken = (NSString *)[[delegate facebook] accessToken];
    NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/fql?q=%@", action];
	
	if (accessToken != nil) {
		//now that any variables have been appended, let's attach the access token....
		url_string = [NSString stringWithFormat:@"%@&access_token=%@", url_string, accessToken];
	}
	//encode the string
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    DebugLog(@"URL STRING: %@", url_string);
    NSURL * sourceURL = [NSURL URLWithString:url_string];
    [self doAsynchGraphGetWithUrlString:sourceURL];
}
-(void)doAsynchGraphGetWithUrlString:(NSURL *)sourceURL{
    //Asynchronous web request through block gets facebook info
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:sourceURL];
    [request setCompletionBlock:^{
        DebugLog(@"returnd succes");
        SBJSON *parser = [[SBJSON alloc] init];
        NSString *responseString = [request responseString];
        NSDictionary *parsed_json = [parser objectWithString:responseString error:nil];	
        //Data encapsulates request
         NSDictionary* data = (NSDictionary *)[parsed_json objectForKey:@"data"]; 
        
        //Dispatch thread processing in a background queue
        MappMeAppDelegate* delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
        dispatch_async(delegate.backgroundQueue, ^(void) {
            [self parseFacebookInfoController:data];
        });
        
    }];
    [request setFailedBlock:^{
        DebugLog(@"returnd failure");
        NSError *error = [request error];
        NSLog(@"Error from Graph Api: %@", error.localizedDescription);
    }];
    [request startAsynchronous]; 
}

//Synchronous Version of FB Graph Requests
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
//	DebugLog(@"URL STRING: %@", url_string);
    
    url_string = [self doGraphGetWithUrlString:url_string];
    SBJSON *parser = [[SBJSON alloc] init];
	NSDictionary *parsed_json = [parser objectWithString:url_string error:nil];	
    //Data encapsulates request
	NSDictionary *data = (NSDictionary *)[parsed_json objectForKey:@"data"];
    return data;
}

#pragma mark - parsing methods for data processing
-(void)parseFbFriends:(NSDictionary*)bas_info andCityType:(NSString*)locTypeString{
    NSDictionary *friendsTemp;
    NSDictionary *friends = [bas_info objectForKey:@"fql_result_set"];
    NSEnumerator *friendsEnum = [friends objectEnumerator];
    
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

    while ((friendsTemp = (NSDictionary *)[friendsEnum nextObject])) {
        if([[friendsTemp objectForKey:locTypeString]count]==0){
            //If empty entry for location, continue
            continue;
        }
//        NSArray* keys = [friendsTemp allKeys];
//        NSLog(@"%@ %@ %@", [keys objectAtIndex:0], [keys objectAtIndex:1], [keys objectAtIndex:2]);
//        NSArray* vals = [friendsTemp allValues];
//        NSLog(@"%@ %@ %@", [vals objectAtIndex:0], [vals objectAtIndex:1], [vals objectAtIndex:2]);

        //NSString * uid = [NSString stringWithFormat:@"%d", [friendsTemp objectForKey:@"uid"]];
        NSString * uid = (NSString*)[friendsTemp objectForKey:@"uid"];
        NSString * town_id = [[friendsTemp objectForKey:locTypeString]objectForKey:@"id"];
        NSString * town_name = [[friendsTemp objectForKey:locTypeString]objectForKey:@"name"];
        NSString *name = [friendsTemp objectForKey:@"name"];
        
        [mainDataManager.placeContainer addId:town_id andPlaceName:town_name];
        [mainDataManager.peopleContainer setPersonPlaceInContainer:name personId:uid placeId:town_id andTypeId:locType];
        
    }
    if(locType == tHomeTown){
        [dataProgressUpdater setTotal:[[mainDataManager.peopleContainer getFriendGroupingForLocType:tHomeTown]count] forType:tHomeTown];
    }
}
/* Location Queries From Facebook:  Adds an Dictionary of cities and facbeook ids to mapping*/
-(void)parseFbCity:(NSDictionary*)bas_info{
    NSDictionary *citiesTemp;
    NSDictionary *coords = [bas_info objectForKey:@"fql_result_set"];
    NSEnumerator *citiesEnum = [coords objectEnumerator];
    while ((citiesTemp = [citiesEnum nextObject])) {
        NSDictionary *loc= [citiesTemp objectForKey:@"location"];
        
        /*Make sure location array is not empty*/
        if ([loc respondsToSelector:@selector(objectForKey:)]) {
            [[mainDataManager placeContainer]addCoordsLat:[loc objectForKey:@"latitude"] andLong:[loc objectForKey:@"longitude"] forPlaceId:[citiesTemp objectForKey:@"page_id"]];
            //Check if it's hometown, then init
            if([dataProgressUpdater hometownSet]){
                [dataProgressUpdater incrementSum:tHomeTown];
            }
        }
        else{
            NSString * page_id = [citiesTemp objectForKey:@"page_id"];
            DebugLog(@"%@ not found; id: %@",[mainDataManager.placeContainer getPlaceNameFromId:page_id],page_id);
        }
    }
}
-(void)parseFbEdu:(NSDictionary*)bas_info{
    NSDictionary *schoolTemp;
    NSEnumerator *schoolLocEnum = [[bas_info objectForKey:@"fql_result_set"] objectEnumerator];
    while ((schoolTemp = [schoolLocEnum nextObject])) {
        if ([(NSString *)[schoolTemp objectForKey:@"name"]length] >3){
            NSDictionary *loc= [schoolTemp objectForKey:@"location"];
            NSString * school_id = [schoolTemp objectForKey:@"page_id"];
            NSString *type = [schoolTypeMapping objectForKey:school_id];
            //If have lat and long
            if ([loc objectForKey:@"latitude"]){
                [[mainDataManager placeContainer]addCoordsLat:[loc objectForKey:@"latitude"] andLong:[loc objectForKey:@"longitude"] forPlaceId:school_id];
            }else{
                [mainDataManager.placeContainer doCoordLookupAndSet:school_id withDict:loc andTypeString:type];
            }
            if (type!= nil){
                locTypeEnum lt = [LocationTypeEnum getEnumFromName:type];
                [dataProgressUpdater incrementSum:lt];
            }
        }
        
    }
    [dataProgressUpdater setFinishedTotal:tHighSchool];
    [dataProgressUpdater setFinishedTotal:tCollege];
    [dataProgressUpdater setFinishedTotal:tGradSchool];
    [dataProgressUpdater endLoader];
}
-(void)parseFbFriendsEdu:(NSDictionary*)bas_info{
    NSDictionary *friendsTemp;
    NSDictionary *friendsEdu = [bas_info objectForKey:@"fql_result_set"];
    NSEnumerator *friendsEnum = [friendsEdu objectEnumerator];
    //used for progress updater
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
            [mainDataManager.placeContainer addId:school_id andPlaceName:school_name];
            [mainDataManager.peopleContainer setPersonPlaceInContainer:name personId:uid placeId:school_id andTypeId:placeType];
        }
    }
    //Set totals for progress updater
    [dataProgressUpdater setTotal:[[mainDataManager.peopleContainer getFriendGroupingForLocType:tHighSchool]count] forType:tHighSchool];
    [dataProgressUpdater setTotal:[[mainDataManager.peopleContainer getFriendGroupingForLocType:tCollege]count] forType:tCollege];
    [dataProgressUpdater setTotal:[[mainDataManager.peopleContainer getFriendGroupingForLocType:tGradSchool]count] forType:tGradSchool];
}
-(void)parseFacebookInfoController: (NSDictionary *)infoArray{
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
        
        //CityType param allows reuse of parsing method for fb friend/city info while differentiating data
        if ([loc isEqualToString :@"curLocFriends"]){
            [self parseFbFriends:bas_info andCityType:@"current_location"];
        }
        if ([loc isEqualToString :@"hometownFriends"]){
            [self parseFbFriends:bas_info andCityType:@"hometown_location"];
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
    
    DebugLog(@"Number of friends %i", [mainDataManager.peopleContainer getNumPeople]);
    DebugLog(@"Number of cities %i",[mainDataManager.placeContainer getNumPlaces]);
    
//    [delegate.peopleContainer printGroupings:tHomeTown];
//    [delegate.peopleContainer printGroupings:tCurrentLocation];
}

#pragma mark - Query String Facebook Data Retrieval Methods
-(void)getCurrentLocation{
    
    NSString* fql1 = [NSString stringWithFormat:
                      @"SELECT name,uid, current_location.name, current_location.id FROM user WHERE  uid IN (SELECT uid2 FROM friend WHERE uid1= me()) AND current_location>0 ORDER BY current_location DESC"];
    
    NSString* fql2 = [NSString stringWithFormat:
                      @"SELECT location.latitude,location.longitude,page_id FROM page WHERE page_id IN (SELECT current_location FROM #curLocFriends)"];
    NSString* fqlC = [NSString stringWithFormat:
                      @"{\"curLocFriends\":\"%@\",\"location\":\"%@\"}",fql1,fql2];
    NSDictionary *response = [self doMultiQuery:fqlC];  
    [self parseFacebookInfoController:response];
    
}
-(void)getHometownLocation{
    
    NSString* fqlH1 = [NSString stringWithFormat:
                       @"SELECT name,uid, hometown_location.name, hometown_location.id FROM user WHERE  uid IN (SELECT uid2 FROM friend WHERE uid1= me()) AND hometown_location>0 ORDER BY hometown_location DESC "];
    
    NSString* fqlH2 = [NSString stringWithFormat:
                       @"SELECT location.latitude,location.longitude,name,page_id FROM page WHERE page_id IN (SELECT hometown_location FROM #hometownFriends)"];
    NSString* fqlH = [NSString stringWithFormat:
                      @"{\"hometownFriends\":\"%@\",\"location\":\"%@\"}",fqlH1,fqlH2];
    [self asynchMultQueryHelper:fqlH];
//    NSDictionary *response = [self doMultiQuery:fqlH];  
//    [self parseFacebookInfoController:response];    
    
}
-(void)getEducationInfo{
    NSString* fqlE1 = [NSString stringWithFormat:
                       @"SELECT name, uid, education FROM user WHERE  uid IN (SELECT uid2 FROM friend WHERE uid1= me())"];
    NSString* fqlE2 = [NSString stringWithFormat:
                       @"SELECT location,name,page_id FROM page WHERE page_id IN (SELECT education FROM #friendsEdu)"];
    NSString* fqlE = [NSString stringWithFormat:
                      @"{\"friendsEdu\":\"%@\",\"schoolLocation\":\"%@\"}",fqlE1,fqlE2];
    [self asynchMultQueryHelper:fqlE];
//    NSDictionary *response = [self doMultiQuery:fqlE];  
//    [self parseFacebookInfoController:response];  
}


@end
