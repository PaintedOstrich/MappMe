//
//  FacebookDataHandler.m
//  MappMe
//
//  Created by Parker Spielman on 3/23/12.
//  Copyright (c) 2012 Painted Ostrich. All rights reserved.
//

#import "FacebookDataHandler.h"
#import "MappMeAppDelegate.h"
#import "DebugLog.h"
#import "AFJSONRequestOperation.h"
#import "DataManagerSingleton.h"
#import "CoordinateLookupManager.h"
#import <objc/runtime.h>
#import "UtilFunctions.h"
static FacebookDataHandler *FBHandler = nil;

@implementation FacebookDataHandler{
    //NSMutableDictionary *schoolTypeMapping;
    DataManagerSingleton * mainDataManager;
    //HTTP request operation queue
    NSOperationQueue *queue;
}

#pragma mark Singleton Methods
+ (id)sharedInstance {
    @synchronized(self) {
        if (FBHandler == nil) {
            FBHandler = [[self alloc] init];
        }
    }
    return FBHandler;
}

-(id)init{
    if(self = [super init]){
        mainDataManager = [DataManagerSingleton sharedManager];
        queue = [[NSOperationQueue alloc] init];
    }
    return self;
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
    DebugLog(@"query:\n %@",[NSURL URLWithString:url_string]);
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
                                             NSLog(@"Error from Graph Api: %@", error.localizedDescription);
                                             DebugLog(@"Retrying....");
                                             [self asynchMultQueryHelper:action];
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
        NSLog(@"Query Error: %@, Retrying....", error);
        return [self doSyncMultiQuery:action];
    }

	NSDictionary *data = [self parseJSON:jsonString];
    return data;
}

#pragma mark - parsing methods for data processing
-(void)parseFbFriends:(NSDictionary*)bas_info andCityType:(NSString*)locTypeString{
    NSDictionary *friendsTemp;
    NSArray *friends = [bas_info objectForKey:@"fql_result_set"];
    if ([friends isKindOfClass:[NSArray class]]) {
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

        while ((friendsTemp = [friendsEnum nextObject])) {
            if ([friendsTemp isKindOfClass:[NSDictionary class]]) {
                NSDictionary* locations = [friendsTemp objectForKey:locTypeString];
                
                if(![locations isKindOfClass:[NSDictionary class]] || [locations count]==0){
                    //If empty entry for location, or location is not even an NSDictionary continue
                    continue;
                }   
                
                NSString * uid = [UtilFunctions convertToString:[friendsTemp objectForKey:@"uid"]];
                //Changed to str value
                NSString * town_id = [UtilFunctions convertToString:[locations objectForKey:@"id"]];
                NSString * town_name = [UtilFunctions convertToString:[locations objectForKey:@"name"]];
                NSString *name = [UtilFunctions convertToString:[friendsTemp objectForKey:@"name"]];
                if (town_id != nil && uid != nil) {
                    Place* place = [mainDataManager.placeContainer get:town_id];
                    place.name = town_name;
                    Person* friend = [mainDataManager.peopleContainer get:uid];
                    friend.name = name;
                    //Establish two way relationship between friend and place (connected by the locType)
                    [self link:place withPerson:friend forLocType:locType];
                }
            } else {
                NSString * nsstr = [ NSString stringWithUTF8String:class_getName([friendsTemp class]) ] ;
                DebugLog(@"friendsTemp in parseFbFriends is %@ instead of NSDictionary", nsstr);

            }
        }
    } else {
        NSString * nsstr = [ NSString stringWithUTF8String:class_getName([friends class]) ] ;
        DebugLog(@"friends in parseFbFriends is %@ instead of NSArray", nsstr);
    }
    
}
/* Location Queries From Facebook:  Adds an Dictionary of cities and facbeook ids to mapping*/
-(void)parseFbCity:(NSDictionary*)bas_info{
    NSDictionary *citiesTemp;
    NSArray *coords = [bas_info objectForKey:@"fql_result_set"];
    
    if ([coords isKindOfClass:[NSArray class]]) {
        NSEnumerator *citiesEnum = [coords objectEnumerator];
        while ((citiesTemp = [citiesEnum nextObject])) {
            NSDictionary *loc= [citiesTemp objectForKey:@"location"];
            if ([loc isKindOfClass:[NSDictionary class]]) {
                NSString* placeId = [UtilFunctions convertToString:[citiesTemp objectForKey:@"page_id"]];
                if (placeId != nil) {
                    Place* place = [[mainDataManager placeContainer] get:placeId];
                    NSString* lat = [UtilFunctions convertToString:[loc objectForKey:@"latitude"]];
                    NSString* lon = [UtilFunctions convertToString:[loc objectForKey:@"longitude"]];  
                    [place addLat:lat andLong:lon];
                }
            } else{
                //In My testing(Di), sometimes loc will be an empty array instead of dictionary.
                NSString * nsstr = [ NSString stringWithUTF8String:class_getName([loc class]) ] ;
                DebugLog(@"loc in parseFbCity is %@ instead of NSDictionary", nsstr);
                //DebugLog([loc description]);
            }
        }
    } else {
        NSString * nsstr = [ NSString stringWithUTF8String:class_getName([coords class]) ] ;
        DebugLog(@"coords in parseFbCity is %@ instead of NSArray", nsstr);
    }
}

-(void)parseSchoolLocations:(NSDictionary*)bas_info{
    NSDictionary *schoolTemp;
    NSArray *schoolLocs = [bas_info objectForKey:@"fql_result_set"];
    
    if ([schoolLocs isKindOfClass:[NSArray class]]) {
        NSEnumerator *schoolLocEnum = [schoolLocs objectEnumerator];
        while ((schoolTemp = [schoolLocEnum nextObject])) {
            if ([schoolTemp isKindOfClass:[NSDictionary class]]) {
                NSDictionary *loc= [schoolTemp objectForKey:@"location"];
                if ([loc isKindOfClass:[NSDictionary class]]) {
                    //If loc is a dictionary which only contains empty strings as value,
                    //then this is a year/concentration page instead of a school page.
                    if ([UtilFunctions hasLoactionData:loc]) {
                        NSString* school_id = [UtilFunctions convertToString:[schoolTemp objectForKey:@"page_id"]];
                        NSString* school_name = [UtilFunctions convertToString:[schoolTemp objectForKey:@"name"]];
                        if (school_id != nil && school_name !=nil) {
                            Place* place = [[mainDataManager placeContainer] get:school_id];
                            if ([loc objectForKey:@"latitude"]){
                                NSString* lat = [UtilFunctions convertToString:[loc objectForKey:@"latitude"]];
                                NSString* lon = [UtilFunctions convertToString:[loc objectForKey:@"longitude"]];  
                                [place addLat:lat andLong:lon];
                            } // Else if place does not have a valid location and it is still not in the black list, then do a google map look up!! 
                            else if (![place hasValidLocation] && ![[[[DataManagerSingleton sharedManager] placeContainer] blacklistedPlaces] containsObject:place.uid]){
                                //loc = { city="ShenZhen";
                                //        country="China";
                                //        state = "";
                                //        zip = "";
                                //      }
                                if (loc) {
                                    [place addMetaData:loc];
                                }
                                [[CoordinateLookupManager sharedManager] lookupLocation:place];
                            }
                        }
                    }
                }
            }  
        }
    } else {
        NSString * nsstr = [ NSString stringWithUTF8String:class_getName([schoolLocs class]) ] ;
        DebugLog(@"schoolLocs in parseSchoolLocations is %@ instead of NSArray", nsstr);
    }
}

-(void)parseFbFriendsEdu:(NSDictionary*)bas_info{
    NSDictionary *friendsEdu;
    NSArray *friends = [bas_info objectForKey:@"fql_result_set"];
    
    if ([friends isKindOfClass:[NSArray class]]) {
        NSEnumerator *friendsEnum = [friends objectEnumerator];
        //used for progress updater
        while ((friendsEdu = [friendsEnum nextObject])) {
            if ([friendsEdu isKindOfClass:[NSDictionary class]]) {
                NSString * uid = [UtilFunctions convertToString:[friendsEdu objectForKey:@"uid"]];
                NSString * name = [UtilFunctions convertToString:[friendsEdu objectForKey:@"name"]];
                NSArray* educations = [friendsEdu objectForKey:@"education"];
                if ([educations isKindOfClass:[NSArray class]]) {
                   NSEnumerator *enumerator = [educations objectEnumerator];
                   NSDictionary *edu;
                    while (edu = [enumerator nextObject]) {
                        if ([edu isKindOfClass:[NSDictionary class]]) {
                            NSDictionary* school = [edu objectForKey:@"school"];
                            if ([school isKindOfClass:[NSDictionary class]]) {
                                NSString * school_id = [UtilFunctions convertToString:[school objectForKey:@"id"]];
                                NSString * school_name = [UtilFunctions convertToString:[school objectForKey:@"name"]];
                                NSString * school_type = [UtilFunctions convertToString:[edu objectForKey:@"type"]];
                                locTypeEnum placeType = [LocationTypeEnum getEnumFromName:school_type];
                                if (school_id != nil && uid != nil) {
                                    //[schoolTypeMapping setObject:school_type forKey:school_id];
                                    Place* place = [mainDataManager.placeContainer get:school_id];
                                    place.name = school_name;
                                    
                                    Person* person = [mainDataManager.peopleContainer get:uid];
                                    person.name = name;
                                    [self link:place withPerson:person forLocType:placeType];
                                }
                                
                            }
                        }
                    }
                }
            }   
        }
    } else {
        NSString * nsstr = [ NSString stringWithUTF8String:class_getName([friends class]) ] ;
        DebugLog(@"friendsEdu in parseFbFriendsEdu is %@ instead of NSArray", nsstr);
    }
}
//Parses mutual friends and stores them as array for person
-(void)parseMutualFriends:(NSDictionary*)bas_info{
    NSDictionary *uids;
    NSArray *mutualFriendsFromFb = [bas_info objectForKey:@"fql_result_set"];
    if ([mutualFriendsFromFb isKindOfClass:[NSArray class]]) {
        NSEnumerator *friendsEnum = [mutualFriendsFromFb objectEnumerator];
        NSString *personId = @"";
        
        NSMutableArray *friendIds = [[NSMutableArray alloc]initWithCapacity:[mutualFriendsFromFb count]];
        while ((uids = [friendsEnum nextObject])) {
            if ([uids isKindOfClass:[NSDictionary class]]){
                if (personId.length <1) {
                     personId = [uids objectForKey:@"uid1"];
                }
                NSString *fid =[uids objectForKey:@"uid2"];
                [friendIds addObject:fid];
            } else {
                NSString * nsstr = [ NSString stringWithUTF8String:class_getName([uids class]) ] ;
                DebugLog(@"uids in parseMutualFriends is %@ instead of NSDictionary", nsstr);
            }
        }

        if (personId != nil) {
            Person* person = [mainDataManager.peopleContainer get:personId];
            [person setMutualFriends:(NSArray*)friendIds];   
            //    DebugLog(@"just set these mutual friends %@",friendIds);
//            DebugLog(@"person Id from result%@", personId)
//            DebugLog(@"freind printout:%@",person.name);
        }
    } else {
        NSString * nsstr = [ NSString stringWithUTF8String:class_getName([mutualFriendsFromFb class]) ] ;
        DebugLog(@"mutualFriendsFromFb in parseMutualFriends is %@ instead of NSArray", nsstr); 
    }
}
-(void)parseFacebookInfoController: (NSDictionary *)data{
    NSArray* infoArray = (NSArray *)[data objectForKey:@"data"]; 
	NSEnumerator *enumerator = [infoArray objectEnumerator];
	NSDictionary *bas_info;

    /* Stores mapping temporarily between school_id and school_type
     Used to help location lookup on Google Maps
     Populated in friendsEdu section
     Used in schoolLocation.  Init here so can be used in multiple calls. should prbly architect better*/
    //schoolTypeMapping = [[NSMutableDictionary alloc] init];

    while ((bas_info = (NSDictionary *)[enumerator nextObject])) {
        //NSCFDictionary is the private subclass of NSDictionary that implements the actual functionality
        //So we should use isKindOfClass check here!
        if ([bas_info isKindOfClass:[NSDictionary class]]) {
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
                [self parseSchoolLocations:bas_info];
            }
            if([loc isEqualToString:@"mutualFriends"]){
                [self parseMutualFriends:bas_info];
            }
        } else {
            NSString * nsstr = [ NSString stringWithUTF8String:class_getName([bas_info class]) ] ;
            DebugLog(@"bas_info in parseFacebookInfoController is %@ instead of NSDictionary", nsstr);
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
    [self asynchMultQueryHelper:fqlE];
}

-(void)getMutualFriends:(NSString*)friendId{
    NSString* mutual = [NSString stringWithFormat:
                       @"SELECT uid1, uid2 FROM friend WHERE uid1 IN (SELECT uid2 FROM friend WHERE uid1=me() AND uid2 = '%@' ) AND uid2 IN (SELECT uid2 FROM friend WHERE uid1=me())", friendId];
        NSString* fql = [NSString stringWithFormat:
                      @"{\"mutualFriends\":\"%@\"}",mutual];
    DebugLog(@"lookup for person Id : %@", friendId);
    [self asynchMultQueryHelper:fql];
}

- (void)getUserPermissions {
    //https://graph.facebook.com/me/permissions
    
    MappMeAppDelegate* delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString * accessToken = (NSString *)[[delegate facebook] accessToken];
    
    NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/me/permissions&access_token=%@",accessToken];
    //encode the string
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    DebugLog(@"query:\n %@",[NSURL URLWithString:url_string]);

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url_string]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             NSDictionary* dic = (NSDictionary*)JSON;
                                             NSArray* permArr = [dic objectForKey:@"data"];
                                             NSDictionary* tmp;
                                             if ([permArr respondsToSelector:@selector(objectAtIndex:)]) {
                                                tmp = [permArr objectAtIndex:0];
                                             } else {
                                                 tmp = nil;
                                             }
                                             NSMutableDictionary* permissions = [[NSMutableDictionary alloc] initWithDictionary:tmp];
                                             if (permissions) {
                                                 [[DataManagerSingleton sharedManager] setUserPermissions:permissions];
                                             } else {
                                               DebugLog(@"ERROR!!!! Unable to parse permissions query from facbook"); 
                                             }
                                             
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             NSLog(@"Error from Graph Api: %@", error.localizedDescription);
                                             DebugLog(@"Retrying....");
                                             [self getUserPermissions];
                                         }];
    operation.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
    [queue addOperation:operation];
}


#pragma mark -- NSOperation management methods
-(void) cancelAllOperations
{
    [queue cancelAllOperations];
}

-(void) haltOperations
{
    [queue setSuspended:TRUE];
}

-(void) resumeOperations
{
    [queue setSuspended:FALSE];
}



@end
