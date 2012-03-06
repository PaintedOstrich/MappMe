/*
 * The main view controller of the app.
 * It is responsible for fetching data from facebook. Creating annotations and
 * addig these annotations to map view with animation.
 */

#import "MainViewController.h"
#import "DebugLog.h"
#import "MappMeAppDelegate.h"
#import "SBJSON.h"
#import "Timer.h"
#import "MyAnnotation.h"
#import "CoordPairs.h"


@interface MainViewController()
-(void)getCurrentLocation;
-(void)getHometownLocation;
-(void) showPins;
@end


@implementation MainViewController{
    MappMeAppDelegate *delegate;
    MBProgressHUD *HUD;
    NSMutableArray * annotations;
    NSMutableArray * annotations2;
}

@synthesize mapView;


#pragma mark - Transition Functions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showdetail"]) {
        
    }
}


/*
 * This method is invoked when the accesory button on annotation view is tapped.
 * Takes the user into a list of friends or the friend's facebook page directly
 */
- (void) showDetail:(id)sender {
    [self performSegueWithIdentifier:@"showdetail" sender:nil];
//    NSArray *listItems = [((UIButton*)sender).currentTitle componentsSeparatedByString:@"?"];
//	NSString *cityName= [listItems objectAtIndex:0];
//    //    DebugLog(@"cityname : %@", cityName);
//    NSString * city_id = [delegate.placeAndId objectForKey:cityName];
//	if([[delegate.friendsArrWithLocAsKey objectForKey:city_id] count]>1){
//		self.userProfileVC.title=cityName;
//		[delegate.currentSelectedCity insertObject:[NSString stringWithFormat:@"%@",cityName] atIndex:0] ;
//		[self.navigationController pushViewController:self.userProfileVC animated:YES];
//	}
//	//only one person, go to the facebook page directly.!
//	else{
//		NSString *fName= [listItems objectAtIndex:1] ;
//        //		DebugLog(@"%@%@",@"name is:",fName);
//		NSString *fId =[delegate.nameAndId objectForKey:fName];
//		NSString *urlStr = [[NSString alloc] initWithFormat:@"%@%@",@"http://m.facebook.com/profile.php?id=",fId];
//		NSURL *url =[[NSURL alloc] initWithString:urlStr];
//		CSWebDetailsViewController* webViewController =[[CSWebDetailsViewController alloc] initWithNibName:@"CSWebDetailsViewController" bundle:nil];
//		[webViewController setUrl:url];
//        
//		[self.navigationController pushViewController:webViewController animated:YES];
//	}
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [mapView setDelegate:self];
    annotations = [[NSMutableArray alloc]initWithCapacity:20];
    annotations2 = [[NSMutableArray alloc]initWithCapacity:20];
    delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    // Show the HUD while the provided method executes in a new thread
    [HUD showWhileExecuting:@selector(fetchAndProcess) onTarget:self withObject:nil animated:YES];
}

-(void) viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:TRUE animated:TRUE];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.mapView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Map pins methods
-(void)makeAnnotationFromDict:(NSDictionary*)groupings{
    NSArray *keys = [groupings allKeys];
    int i, count;
    count = [keys count];
    
    for (i = 0; i < count; i++)
    {
        NSString * placeId = [keys objectAtIndex: i];
        CoordPairs *loc = [delegate.placeIdMapping getCoordFromId:placeId];
        MyAnnotation* myAnnotation1=[[MyAnnotation alloc] init];
        myAnnotation1.coordinate=loc.location;
        myAnnotation1.title=[delegate.placeIdMapping getPlaceFromId:placeId];
        NSSet * groupPerPlace = (NSSet*)[groupings objectForKey: placeId];
//        NSMutableArray *groupPerPlace;
        if([groupPerPlace count]==1){
            NSString *fId= [groupPerPlace anyObject];
            NSString *fName=[delegate.personNameAndIdMapping getNameFromId:fId];
            myAnnotation1.subtitle=fName;
        }
        else {
            myAnnotation1.subtitle=[[NSString alloc] initWithFormat:@"%d%@",[groupPerPlace count],@" friends"];	
        }
        
        //Add in type of Annotation depends on num of friends
        //the bigger the number, more people at that location
        if([groupPerPlace count]>20){
            myAnnotation1.type=3;
        }
        else if([groupPerPlace count]>10){
            myAnnotation1.type=2;
        }
        else if([groupPerPlace count]>3){
            myAnnotation1.type=1;
        }
        else {
            myAnnotation1.type=0;
        }
        
        [annotations addObject:myAnnotation1];

    }

}


-(void)showPins
{
	[mapView addAnnotations:annotations];	
}


- (void)fetchAndProcess {
    /*Call Methods for info*/
    [self getCurrentLocation];
    [self getHometownLocation];
    [self makeAnnotationFromDict:[delegate.peopleContainer getFriendGroupingForLocType:tHomeTown]];
    // Task completed, update view in main thread (note: view operations should
    // be done only in the main thread)
    [self performSelectorOnMainThread:@selector(showPins) withObject:nil waitUntilDone:NO];
}

#pragma mark - Custom Facebook Methods
/* METHOD ADDED FEB 2012, by Parkour */
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

-(void)parseCityAndPeople: (NSDictionary *)infoArray andType:(NSString*)locTypeString{
    
	NSEnumerator *enumerator = [infoArray objectEnumerator];
	NSDictionary *bas_info;
    locTypeEnum locType;
    if ([locTypeString isEqualToString:@"current_location"]){
        locType = tCurrentLocation;
        DebugLog(@"sets locType to current_location");
    } 
    if ([locTypeString isEqualToString:@"hometown_location"]){
        locType = tHomeTown;
        DebugLog(@"sets locType to hometown");
    }
    if (locType != tHomeTown && locType != tCurrentLocation){
        DebugLog(@"Warning: locType set incorrectly");
    }
    
    while ((bas_info = (NSDictionary *)[enumerator nextObject])) {
        NSString * loc = [bas_info objectForKey:@"name"];
        // DebugLog(@"Is equal location: %@", [loc compare:@"location"]);
        //Gets friends and their current location or hometown
        if ([loc isEqualToString :@"friends"]){
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
        //Adds coords retrieved from facebook for cities
        if (![loc compare:@"location"]){
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
    }
    DebugLog(@"Number of friends %i", [delegate.peopleContainer getNumPeople]);
    DebugLog(@"Number of cities %i",[delegate.placeIdMapping getNumPlaces]);
    //    [delegate.peopleContainer printNFriends:400];
    
    [delegate.peopleContainer printGroupings:tHomeTown];
    [delegate.peopleContainer printGroupings:tCurrentLocation];
}
#pragma mark - Caller Methods For Data
-(void)getCurrentLocation{
    Timer *t = [[Timer alloc]init];
    
    NSString* fql1 = [NSString stringWithFormat:
                      @"SELECT name,uid, current_location.name, current_location.id FROM user WHERE  uid IN (SELECT uid2 FROM friend WHERE uid1= me()) AND current_location>0 ORDER BY current_location DESC"];
    
    NSString* fql2 = [NSString stringWithFormat:
                      @"SELECT location.latitude,location.longitude,page_id FROM page WHERE page_id IN (SELECT current_location FROM #friends)"];
    NSString* fqlC = [NSString stringWithFormat:
                      @"{\"friends\":\"%@\",\"location\":\"%@\"}",fql1,fql2];
    NSDictionary *response = [self doMultiQuery:fqlC];  
    [self parseCityAndPeople:response andType:@"current_location"];
    
    
    int total = [t getCurrentTimeInterval];
    DebugLog(@"Total Facebook Load Time in Seconds: %i", total);
}
-(void)getHometownLocation{
    Timer *t = [[Timer alloc]init];
    NSString* fqlH1 = [NSString stringWithFormat:
                       @"SELECT name,uid, hometown_location.name, hometown_location.id FROM user WHERE  uid IN (SELECT uid2 FROM friend WHERE uid1= me()) AND hometown_location>0 ORDER BY hometown_location DESC "];
    
    NSString* fqlH2 = [NSString stringWithFormat:
                       @"SELECT location.latitude,location.longitude,name,page_id FROM page WHERE page_id IN (SELECT hometown_location FROM #friends)"];
    NSString* fqlH = [NSString stringWithFormat:
                      @"{\"friends\":\"%@\",\"location\":\"%@\"}",fqlH1,fqlH2];
    NSDictionary *response = [self doMultiQuery:fqlH];  
    [self parseCityAndPeople:response andType:@"hometown_location"];
    
    
    int total = [t getCurrentTimeInterval];
    DebugLog(@"Total Facebook Load Time in Seconds: %i", total);
}
-(void)getEducationInfo{
    NSString* fqlE1 = [NSString stringWithFormat:
                       @"SELECT name, uid, education FROM user WHERE  uid IN (SELECT uid2 FROM friend WHERE uid1= me())"];
    NSString* fqlE2 = [NSString stringWithFormat:
                       @"SELECT location,name,page_id FROM page WHERE page_id IN (SELECT education FROM #friendsEdu)"];
    NSString* fqlE = [NSString stringWithFormat:
                      @"{\"friendsEdu\":\"%@\",\"location\":\"%@\"}",fqlE1,fqlE2];
    [self doMultiQuery:fqlE];
}

#pragma mark MKMapViewDelegate
/*
 * This method will enable animation of dropping pins
 */
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views { 
    MKAnnotationView *aV; 
    for (aV in views) {
        CGRect endFrame = aV.frame;
        
        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - 230.0, aV.frame.size.width, aV.frame.size.height);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.45];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [aV setFrame:endFrame];
        [UIView commitAnimations];
        
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MyAnnotation *)annotation
{
	//NSLog(@"welcome into the map view annotation");
    
	// if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
	// try to dequeue an existing pin view first
	static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    
	UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	NSString *cityNameAndFName=[[NSString alloc] initWithFormat:@"%@?%@",annotation.title,annotation.subtitle];
	[rightButton setTitle:cityNameAndFName forState:UIControlStateNormal];
	[rightButton addTarget:self
					action:@selector(showDetail:)
		  forControlEvents:UIControlEventTouchUpInside];
    
	if (annotation.type==0){
        
        //The only reason we still need this duplicate block is that MKPinAnnotationView seem to 
        //have a sequential animation that looks better.
        
		MKPinAnnotationView* pinView = [[MKPinAnnotationView alloc]
										 initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
		pinView.animatesDrop=YES;
		pinView.canShowCallout=YES;
		pinView.pinColor=MKPinAnnotationColorGreen;
		pinView.rightCalloutAccessoryView = rightButton;
        
		UIImageView *profileIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile.png"]];
		pinView.leftCalloutAccessoryView = profileIconView;
        
		return pinView;
	}
    
	else{
	    MKAnnotationView* pinView = [[MKPinAnnotationView alloc]
									  initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
		pinView.canShowCallout=YES;
		//check for different type of pin (sizes)
		if(annotation.type==1){
			pinView.image =[UIImage imageNamed:@"bluePin1.25.png"];
		}else if (annotation.type==2){
			pinView.image =[UIImage imageNamed:@"purple1.4.png"];	
		}else{
			pinView.image =[UIImage imageNamed:@"red1.6.png"];	
		}
		pinView.rightCalloutAccessoryView = rightButton;
        
	    UIImageView *profileIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile.png"]];
	    pinView.leftCalloutAccessoryView = profileIconView;
		//  pinView.tag = @"moreThanOnePerson";
        
		return pinView;
        
	}
}

@end
