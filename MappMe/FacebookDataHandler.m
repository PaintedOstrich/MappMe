//
//  FacebookDataHandler.m
//  MappMe
//
//  Created by Parker Spielman on 3/23/12.
//  Copyright (c) 2012 Painted Ostrich. All rights reserved.
//

#import "FacebookDataHandler.h"
#import "LocationTypeEnum.h"
#import "MappMeAppDelegate.h"
#import "DebugLog.h"
#import "DataProgressUpdater.h"
#import "AFJSONRequestOperation.h"
#import "DataManagerSingleton.h"
#import "CoordinateLookupManager.h"

@interface FacebookDataHandler()
-(void)parseFacebookInfoController: (NSDictionary *)infoArray;

@end
@implementation FacebookDataHandler{
    //NSMutableDictionary *schoolTypeMapping;
    DataManagerSingleton * mainDataManager;
    DataProgressUpdater *dataProgressUpdater;
    //HTTP request operation queue
    NSOperationQueue *queue;
}

-(id)init{
    if(self = [super init]){
        mainDataManager = [DataManagerSingleton sharedManager];
        dataProgressUpdater = [[DataProgressUpdater alloc] init];
        queue = [[NSOperationQueue alloc] init];
    }
    return self;
}
//sets progress updater delegate to be main controller, in this case
-(void)setProgressUpdaterDelegate:(id)delegate{
    [dataProgressUpdater setProgressUpdaterDelegate:delegate];
}


//This method establishes two way link between a person and a place given a locType.
//E.g. Tim has St. Louis as its homeTown. St. Louis has Tim as a person considering itself as his hometown.
-(void) link:(Place*)place withPerson:(Person*)person forLocType:(locTypeEnum)locType
{
    [person addPlace:place withType:locType];
    [place addPerson:person forType:locType];
}

#pragma mark - Custom Facebook Server communication methods

-(NSURL*)buildQueryUrl:(NSString*)action
{
    MappMeAppDelegate* delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString * accessToken = (NSString *)[[delegate facebook] accessToken];
    
    NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/fql?q=%@", action];
	
	if (accessToken != nil) {
		//now that any variables have been appended, let's attach the access token....
		url_string = [NSString stringWithFormat:@"%@&access_token=%@", url_string, accessToken];
	}
    //encode the string
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:url_string];
}

//Asynchronous version of Graph Api Calls.  
-(void)asynchMultQueryHelper:(NSString*)action{
    NSURL * sourceURL = [self buildQueryUrl:action];
    NSURLRequest *request = [NSURLRequest requestWithURL:sourceURL];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                              [self parseFacebookInfoController:JSON];
                                             
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             DebugLog(@"returnd failure");
                                             NSLog(@"Error from Graph Api: %@", error.localizedDescription);
                                         }];
    operation.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
    [queue addOperation:operation];
}


#pragma Synchronous Method for Facebook Query

- (NSDictionary *)parseJSON:(NSString *)jsonString
{
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    id resultObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (resultObject == nil) {
        NSLog(@"JSON Error: %@", error);
        return nil;
    }
    
    return resultObject;
}

- (NSDictionary *)doSyncMultiQuery:(NSString *)action {	
    NSURL *url = [self buildQueryUrl:action];
    
    NSError *error;
    NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (jsonString == nil) {
        NSLog(@"Query Error: %@", error);
        return nil;
    }

	NSDictionary *data = [self parseJSON:jsonString];
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

        NSString * uid = (NSString*)[friendsTemp objectForKey:@"uid"];
        NSString * town_id = [[friendsTemp objectForKey:locTypeString]objectForKey:@"id"];
        NSString * town_name = [[friendsTemp objectForKey:locTypeString]objectForKey:@"name"];
        NSString *name = [friendsTemp objectForKey:@"name"];
        
        Place* place = [mainDataManager.placeContainer get:town_id];
        place.name = town_name;
        Person* friend = [mainDataManager.peopleContainer get:uid];
        friend.name = name;
        //Establish two way relationship between friend and place (connected by the locType)
        [self link:place withPerson:friend forLocType:locType];
    }
    if(locType == tHomeTown){
        [dataProgressUpdater setTotal:[[mainDataManager.placeContainer getPlacesUsedAs:tHomeTown]count] forType:tHomeTown];
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
            NSString* placeId = [citiesTemp objectForKey:@"page_id"];
            Place* place = [[mainDataManager placeContainer] get:placeId];
            [place addLat:[loc objectForKey:@"latitude"] andLong:[loc objectForKey:@"longitude"]];
        } else{
            //NSString * page_id = [citiesTemp objectForKey:@"page_id"];
            //DebugLog(@"%@ not found; id: %@",[mainDataManager.placeContainer getPlaceNameFromId:page_id],page_id);
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
            //NSString *type = [schoolTypeMapping objectForKey:school_id];
            //If have lat and long
            Place* place = [[mainDataManager placeContainer] get:school_id];
            if ([loc objectForKey:@"latitude"]){
                [place addLat:[loc objectForKey:@"latitude"]  andLong:[loc objectForKey:@"longitude"]]; 
            } else {
                [[CoordinateLookupManager sharedManager] lookupLocation:place];
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

            //[schoolTypeMapping setObject:school_type forKey:school_id];
            Place* place = [mainDataManager.placeContainer get:school_id];
            place.name = school_name;
            
            Person* person = [mainDataManager.peopleContainer get:uid];
            person.name = name;
            [self link:place withPerson:person forLocType:placeType];
        }
    }
    //Set totals for progress updater
    [dataProgressUpdater setTotal:[[mainDataManager.placeContainer getPlacesUsedAs:tHighSchool]count] forType:tHighSchool];
    [dataProgressUpdater setTotal:[[mainDataManager.placeContainer getPlacesUsedAs:tCollege]count] forType:tCollege];
    [dataProgressUpdater setTotal:[[mainDataManager.placeContainer getPlacesUsedAs:tGradSchool]count] forType:tGradSchool];
}
-(void)parseFacebookInfoController: (NSDictionary *)data{
    NSDictionary* infoArray = (NSDictionary *)[data objectForKey:@"data"]; 
	NSEnumerator *enumerator = [infoArray objectEnumerator];
	NSDictionary *bas_info;

    /* Stores mapping temporarily between school_id and school_type
     Used to help location lookup on Google Maps
     Populated in friendsEdu section
     Used in schoolLocation.  Init here so can be used in multiple calls. should prbly architect better*/
    //schoolTypeMapping = [[NSMutableDictionary alloc] init];

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
    
    DebugLog(@"Number of friends %i", [mainDataManager.peopleContainer count]);
    DebugLog(@"Number of cities %i",[mainDataManager.placeContainer count]);
    
}

#pragma mark - Query String Facebook Data Retrieval Methods
-(void)getCurrentLocation{
    
    NSString* fql1 = [NSString stringWithFormat:
                      @"SELECT name,uid, current_location.name, current_location.id FROM user WHERE  uid IN (SELECT uid2 FROM friend WHERE uid1= me()) AND current_location>0 ORDER BY current_location DESC"];
    
    NSString* fql2 = [NSString stringWithFormat:
                      @"SELECT location.latitude,location.longitude,page_id FROM page WHERE page_id IN (SELECT current_location FROM #curLocFriends)"];
    NSString* fqlC = [NSString stringWithFormat:
                      @"{\"curLocFriends\":\"%@\",\"location\":\"%@\"}",fql1,fql2];
    NSDictionary *response = [self doSyncMultiQuery:fqlC];  
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
    
}
-(void)getEducationInfo{
    NSString* fqlE1 = [NSString stringWithFormat:
                       @"SELECT name, uid, education FROM user WHERE  uid IN (SELECT uid2 FROM friend WHERE uid1= me())"];
    NSString* fqlE2 = [NSString stringWithFormat:
                       @"SELECT location,name,page_id FROM page WHERE page_id IN (SELECT education FROM #friendsEdu)"];
    NSString* fqlE = [NSString stringWithFormat:
                      @"{\"friendsEdu\":\"%@\",\"schoolLocation\":\"%@\"}",fqlE1,fqlE2];
   // DebugLog(@"Education Query: \n%@",fqlE);
    [self asynchMultQueryHelper:fqlE];
}

@end
