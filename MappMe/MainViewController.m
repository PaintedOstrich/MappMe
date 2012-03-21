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
#import "WebViewController.h"
#import "ListViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface MainViewController()
-(void)getCurrentLocation;
-(void)getHometownLocation;
-(void)getEducationInfo;
-(void)showPins;
/*View Change Methods*/
-(void)showLocationType:(locTypeEnum)locType;
-(void)showHometown;
-(void)showCurrentLoc;
-(void)showHighSchool;
-(void)showCollege;
-(void)showGrad;
-(void)showFriend:(NSString *)friendId;
-(void)removeSearchTable;

@end


@implementation MainViewController{
    MappMeAppDelegate *delegate;
    MBProgressHUD *HUD;
    NSMutableArray * annotations;
    NSString *selectedCity;
    NSString *selectedPerson;
    
    IBOutlet UITableView *tableView;
    UIView *displayTypeContainer;
    UIView *personSearchContainer;
    BOOL displayTypeContainerIsShown;
    locTypeEnum currDisplayedType;
    
}

@synthesize mapView;



#pragma mark - Transition Functions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"showdetaillist"]) {
        ListViewController *controller = segue.destinationViewController;
        controller.selectedCity = selectedCity;
    } else if ([segue.identifier isEqualToString:@"showwebview"]){
        NSString *fId =[delegate.personNameAndIdMapping getIdFromName:selectedPerson];
		NSString *urlStr = [[NSString alloc] initWithFormat:@"%@%@",@"http://m.facebook.com/profile.php?id=",fId];
		NSURL *url =[[NSURL alloc] initWithString:urlStr];
        WebViewController *controller = segue.destinationViewController;
        controller.url = url;
    }
}


/*
 * This method is invoked when the accesory button on annotation view is tapped.
 * Takes the user into a list of friends or the friend's facebook page directly
 */
- (void) showDetail:(id)sender {
//   
    NSArray *annotationStrings = [((UIButton*)sender).currentTitle componentsSeparatedByString:@"?"];
	selectedCity = [annotationStrings objectAtIndex:0];
    NSString * city_id = [delegate.placeIdMapping getIdFromPlace:selectedCity];

    NSDictionary * currentGrouping = [delegate.peopleContainer getCurrentGrouping];
    NSDictionary * peopleInPlace = [currentGrouping objectForKey:city_id];
	if([peopleInPlace count]>1){
        [self performSegueWithIdentifier:@"showdetaillist" sender:nil];
	}
	//only one person, go to the facebook page directly.!
	else {
		selectedPerson= [annotationStrings objectAtIndex:1] ;
        [self performSegueWithIdentifier:@"showwebview" sender:nil];
	}
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark - Helper View Change Methods

-(void)showHometown{
    [self showLocationType:tHomeTown];
}
-(void)showCurrentLoc{
    [self showLocationType:tCurrentLocation];
}
-(void)showHighSchool{
    [self showLocationType:tHighSchool];
}
-(void)showCollege{
    [self showLocationType:tCollege];
}
-(void)showGrad{
    [self showLocationType:tGradSchool];
}
#pragma mark - Custom Person Search and Button Views 
-(NSArray*) getFriendsInCity:(NSString*) cityName{
    NSString * city_id = [delegate.placeIdMapping getIdFromPlace:selectedCity];
    
    NSDictionary * currentGrouping = [delegate.peopleContainer getCurrentGrouping];
    return [[currentGrouping objectForKey:city_id] allObjects];
}

/* FIXME must subclass view to get this method to work, so we can call close on touch outside of subview
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;
{
    DebugLog(@"testing hit vieW");
    if(displayTypeContainerIsShown){
        UIView * hitView = [displayTypeContainer hitTest:point withEvent:event];
        if ([hitView isEqual:displayTypeContainer])
            DebugLog(@"Hiding superview");
            [displayTypeContainer removeFromSuperview];
    }
    else{
        DebugLog(@"touching buttons");
    }
    return nil;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch=[touches anyObject];
    if([touch view]==displayTypeContainer){
        DebugLog(@"Touched container");
    }
    else{
        DebugLog(@"touched something else");
    }
}
*/
-(IBAction)showList{
    
    displayTypeContainerIsShown = TRUE;
    
    displayTypeContainer = [[UIView alloc] initWithFrame:CGRectMake(40, 90, 240, 280)];
    [displayTypeContainer setAlpha:0.0];
    [displayTypeContainer.layer setBackgroundColor:[[UIColor clearColor] CGColor]];
    
    
    UIView *displayTypeView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 280)];
    [displayTypeView setAlpha:0.65];
    [displayTypeContainer addSubview:displayTypeView];
    
    /*Navigation Buttons*/
    UIButton *curButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [curButton addTarget:self 
                 action:@selector(showCurrentLoc)
     forControlEvents:UIControlEventTouchDown];
    [curButton setTitle:@"Current Location" forState:UIControlStateNormal];
    curButton.frame = CGRectMake(30.0, 20, 180.0, 40.0);
    curButton.highlighted = (tCurrentLocation == currDisplayedType);
    curButton.enabled = (tCurrentLocation != currDisplayedType);
    [displayTypeContainer addSubview:curButton];
    
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [homeButton addTarget:self 
               action:@selector(showHometown)
     forControlEvents:UIControlEventTouchDown];
    [homeButton setTitle:@"Hometown" forState:UIControlStateNormal];
    homeButton.frame = CGRectMake(30.0, 70, 180.0, 40.0);
    homeButton.highlighted = (tHomeTown == currDisplayedType);
    homeButton.enabled = (tHomeTown != currDisplayedType);
    [displayTypeContainer addSubview:homeButton];
    
    UIButton *highButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [highButton addTarget:self 
                   action:@selector(showHighSchool)
         forControlEvents:UIControlEventTouchDown];
    [highButton setTitle:@"High School" forState:UIControlStateNormal];
    highButton.frame = CGRectMake(30.0, 120, 180.0, 40.0);
    highButton.highlighted = (tHighSchool == currDisplayedType);
    highButton.enabled = (tHighSchool != currDisplayedType);
    [displayTypeContainer addSubview:highButton];

    UIButton *collButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [collButton addTarget:self 
                   action:@selector(showCollege)
         forControlEvents:UIControlEventTouchDown];
    [collButton setTitle:@"College" forState:UIControlStateNormal];
    collButton.frame = CGRectMake(30.0, 170, 180.0, 40.0);
    collButton.highlighted = (tCollege == currDisplayedType);
    collButton.enabled = (tCollege != currDisplayedType);
    [displayTypeContainer addSubview:collButton];

    UIButton *gradButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [gradButton addTarget:self 
                   action:@selector(showGrad)
         forControlEvents:UIControlEventTouchDown];
    [gradButton setTitle:@"Graduate School" forState:UIControlStateNormal];
    gradButton.frame = CGRectMake(30.0, 220, 180.0, 40.0);
    gradButton.highlighted = (tGradSchool == currDisplayedType);
    gradButton.enabled = (tGradSchool != currDisplayedType);
    [displayTypeContainer addSubview:gradButton];
    /*End Navigation Buttons*/

    //Rounded Container Corners
    CALayer *dtc = displayTypeView.layer;
    [dtc setMasksToBounds:YES];
    [dtc setCornerRadius:8.0f];
    [dtc setBorderWidth:2.0f];
    [dtc setBorderColor: [[UIColor blackColor] CGColor]];
    [dtc setBackgroundColor: [[UIColor blueColor] CGColor]];
    
    //Add View To Screen
    [self.view addSubview:displayTypeContainer];
    [UIView beginAnimations:nil context:nil];
    [displayTypeContainer setAlpha:1.0];
    [UIView commitAnimations];

}
-(IBAction)showSearchResults{
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 280, 400)];
    tableView.backgroundColor = [UIColor blueColor];
    [tableView setAlpha:0.0];
    NSIndexPath *ip = [[NSIndexPath alloc] initWithIndex:1];
    [[tableView delegate] tableView:tableView didDeselectRowAtIndexPath:ip];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self 
               action:@selector(closeButton:)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Close" forState:UIControlStateNormal];
    button.frame = CGRectMake(80.0, 390, 120.0, 40.0);
    
    
//    [self.view addSubview:tableView];
    //Fixme add alpha to partially transparent  
    personSearchContainer = [[UIView alloc] initWithFrame:CGRectMake(20, 44, 280, 440)];
    //    contentView.autoresizesSubviews = YES;
    //    contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    personSearchContainer.backgroundColor = [UIColor redColor];
    [personSearchContainer addSubview:tableView];
    [personSearchContainer addSubview:button];
    
    //Rounded Corners
    CALayer *psc = tableView.layer;
    [psc setMasksToBounds:YES];
    [psc setCornerRadius:8.0f];
    [psc setBorderWidth:1.0f];
    [psc setBorderColor: [[UIColor blackColor] CGColor]];
    [personSearchContainer.layer setBackgroundColor: [[UIColor clearColor] CGColor]];
    
    [self.view addSubview:personSearchContainer];
    [UIView beginAnimations:nil context:nil];
    [tableView setAlpha:0.65];
    [UIView commitAnimations];
    
    NSArray * friendsIds = [[delegate personNameAndIdMapping] getFriendsWithName:@"eric"];
   // DebugLog(@"matching friends \n %@", friendsIds);
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    DebugLog(@"checks this methods 2");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
//    return [friendIds count];
    DebugLog(@"checks this methods 3");
    return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DebugLog(@"checks this methods 5");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSArray *friendIds = [[delegate personNameAndIdMapping] getAllFriendIds];
    NSString *uid = [friendIds objectAtIndex:indexPath.row];
    cell.textLabel.text = [[delegate personNameAndIdMapping] getNameFromId:uid];
//    cell.detailTextLabel.text = [item objectForKey:@"secondaryTitleKey"];
//    NSString *path = [[NSBundle mainBundle] pathForResource:[item objectForKey:@"imageKey"] ofType:@"png"];
//    UIImage *theImage = [UIImage imageWithContentsOfFile:path];
    cell.imageView.image = [[delegate fbImageHandler] getProfPicFromId:uid];
    return cell;
}
#pragma mark UITableViewDelegate Methods

- (void) tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *) indexPath{
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *uid = [[delegate personNameAndIdMapping] getIdFromName:cell.textLabel.text];
    [self showFriend:uid];
    [self removeSearchTable];
}
/*Table Delegate Helpers*/
- (void)closeButton:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [personSearchContainer setAlpha:0.0];
    [UIView commitAnimations];
    [self removeSearchTable];
    //    [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
}
-(void)removeSearchTable{
    [personSearchContainer removeFromSuperview];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [mapView setDelegate:self];
    annotations = [[NSMutableArray alloc]initWithCapacity:20];
    delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    
    //Set Bools for view methods
    displayTypeContainerIsShown = FALSE;
    
    
    
    // Show the HUD while the provided method executes in a new thread
    [HUD showWhileExecuting:@selector(fetchAndProcess) onTarget:self withObject:nil animated:YES];
}

-(void) viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:TRUE animated:TRUE];
}

-(void) viewWillDisappear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:FALSE animated:TRUE];
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
    annotations = [[NSMutableArray alloc] initWithCapacity:[groupings count]];
    NSArray *keys = [groupings allKeys];
    int i, count;
    count = [keys count];
    for (i = 0; i < count; i++)
    {
        NSString * placeId = [keys objectAtIndex: i];
        CoordPairs *loc = [delegate.placeIdMapping getCoordFromId:placeId];
        if (!loc) {
            //If this location is Null
            DebugLog(@"%@ does not have location",[delegate.placeIdMapping getPlaceFromId:placeId]);
            continue;
        }
        MyAnnotation* annotationItem=[[MyAnnotation alloc] init];
        annotationItem.coordinate=loc.location;
        annotationItem.title=[delegate.placeIdMapping getPlaceFromId:placeId];
        NSSet * groupPerPlace = (NSSet*)[groupings objectForKey: placeId];
        if([groupPerPlace count]==1){
            NSString *fId= [groupPerPlace anyObject];
            NSString *fName=[delegate.personNameAndIdMapping getNameFromId:fId];
            annotationItem.subtitle=fName;
        }
        else {
            annotationItem.subtitle=[[NSString alloc] initWithFormat:@"%d%@",[groupPerPlace count],@" friends"];	
        }
        //Add in type of Annotation depends on num of friends
        //the bigger the number, more people at that location
        if([groupPerPlace count]>20){
            annotationItem.type=3;
        }
        else if([groupPerPlace count]>10){
            annotationItem.type=2;
        }
        else if([groupPerPlace count]>3){
            annotationItem.type=1;
        }
        else {
            annotationItem.type=0;
        }
        [annotations addObject:annotationItem];
    }
}
-(void)getLocationsForFriend:(Friend *)friend{  
    annotations = [[NSMutableArray alloc]initWithCapacity:10];
    for (int type =0; type<tLocationTypeCount; type++){
        locTypeEnum locType = type;
                /*If only one value per field */
        if (![LocationTypeEnum isArrayType:locType]){
            DebugLog(@"%@",friend);
            if([friend hasEntryForType:locType]){
                MyAnnotation* annotationItem=[[MyAnnotation alloc] init];
                NSString *placeId = [friend getStringEntryForLocType:locType];
                CoordPairs *loc = [delegate.placeIdMapping getCoordFromId:placeId];
                annotationItem.coordinate=loc.location;
                annotationItem.type=locType;
                annotationItem.subtitle = [LocationTypeEnum getNameFromEnum:locType];
                annotationItem.title = [delegate.placeIdMapping getPlaceFromId:placeId];
                [annotations addObject:annotationItem];
            }
        } /*Dealing with Array of possible Values */
        else{
            if([friend hasEntryForType:locType]){
                NSEnumerator *itemEnum = [[friend getArrayEntryForLocType:locType]objectEnumerator];
                NSString *placeId;
                while (placeId = [itemEnum nextObject]) {
                    CoordPairs *loc = [delegate.placeIdMapping getCoordFromId:placeId];
                    /*Checks for Valid Coordinate (not valid if not found from Google Lookup)*/
                    if (loc){
                        MyAnnotation* annotationItem=[[MyAnnotation alloc] init];
                        annotationItem.coordinate=loc.location;
                        annotationItem.type=locType;
                        annotationItem.subtitle = [LocationTypeEnum getNameFromEnum:locType];
                        annotationItem.title = [delegate.placeIdMapping getPlaceFromId:placeId];
                        [annotations addObject:annotationItem];
                    }
                }
            }    
        }
       
    }
}
-(void)showPins
{
	[mapView addAnnotations:annotations];	
}
-(void)clearMap{
    [mapView removeAnnotations:annotations];
}
-(void)showLocationType:(locTypeEnum)locType{
    if(displayTypeContainerIsShown){
        [displayTypeContainer removeFromSuperview];
        [self clearMap];
        displayTypeContainerIsShown = FALSE;
    }
    currDisplayedType = locType;
    NSString * buttonLabel= [LocationTypeEnum getNameFromEnum:currDisplayedType];
    [displayTypeButtonLabel setTitle:buttonLabel forState:UIControlStateNormal];
    [displayTypeButtonLabel setTitle:buttonLabel forState:UIControlStateHighlighted];
    [displayTypeButtonLabel setTitle:buttonLabel forState:UIControlStateDisabled];
    [displayTypeButtonLabel setTitle:buttonLabel forState:UIControlStateSelected];
    switch(locType){
        case tHomeTown:
            [self makeAnnotationFromDict:[delegate.peopleContainer getFriendGroupingForLocType:tHomeTown]];
            break;
        case tCurrentLocation:
            [self makeAnnotationFromDict:[delegate.peopleContainer getFriendGroupingForLocType:tCurrentLocation]];
            break;
        case tHighSchool:
            [self makeAnnotationFromDict:[delegate.peopleContainer getFriendGroupingForLocType:tHighSchool]];
            break;
        case tCollege:
            [self makeAnnotationFromDict:[delegate.peopleContainer getFriendGroupingForLocType:tCollege]];
            break;
        case tGradSchool:
            [self makeAnnotationFromDict:[delegate.peopleContainer getFriendGroupingForLocType:tGradSchool]];
            break;
        case tWork:
           [self makeAnnotationFromDict:[delegate.peopleContainer getFriendGroupingForLocType:tWork]];
            break;
        default:
            DebugLog(@"Warning: hitting default case");
    }
    [self showPins];
}
-(void)showFriend:(NSString *)friendId{
    [self clearMap];
    [self getLocationsForFriend:[delegate.peopleContainer getFriendFromId:friendId]];
    [self showPins];
    NSString * buttonLabel= [[delegate personNameAndIdMapping] getNameFromId:friendId];
    [displayTypeButtonLabel setTitle:buttonLabel forState:UIControlStateNormal];
    [displayTypeButtonLabel setTitle:buttonLabel forState:UIControlStateHighlighted];
    [displayTypeButtonLabel setTitle:buttonLabel forState:UIControlStateDisabled];
    [displayTypeButtonLabel setTitle:buttonLabel forState:UIControlStateSelected];
}


- (void)fetchAndProcess {
    Timer * t = [[Timer alloc] init];
    /*Call Methods for info*/
    [self getCurrentLocation];
    [self getHometownLocation];
    //[self getEducationInfo];
    
    [self showLocationType:tCurrentLocation];
    // Task completed, update view in main thread (note: view operations should
    // be done only in the main thread)
//    [self showFriend:[delegate.personNameAndIdMapping getIdFromName:@"Eric Hamblett"]];
//    [self performSelectorOnMainThread:@selector(showPins) withObject:nil waitUntilDone:NO];
    int time = [t endTimerAndGetTotalTime];
    DebugLog(@"Total App Loadtime: %i",time);
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
    locTypeEnum locType = tLocationTypeCount;
    if ([locTypeString isEqualToString:@"current_location"]){
        locType = tCurrentLocation;
    } 
    if ([locTypeString isEqualToString:@"hometown_location"]){
        locType = tHomeTown;
    }
    if (locType != tHomeTown && locType != tCurrentLocation){
        DebugLog(@"Warning: locType set incorrectly");
    }
    /* Stores mapping temporarily between school_id and school_type
        Used to help location lookup on Google Maps
            Populated in friendsEdu section
            Used in schoolLocation
     */
    NSMutableDictionary *schoolTypeMapping = [[NSMutableDictionary alloc] init];
    
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
        if ([loc isEqualToString:@"friendsEdu"]){
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
        /* Location Queries */
        if ([loc isEqualToString:@"location"]){
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
        if ([loc isEqualToString:@"schoolLocation"]){
            DebugLog(@" school location");
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
    }
    DebugLog(@"Number of friends %i", [delegate.peopleContainer getNumPeople]);
    DebugLog(@"Number of cities %i",[delegate.placeIdMapping getNumPlaces]);
    
    [delegate.peopleContainer printGroupings:tHomeTown];
    [delegate.peopleContainer printGroupings:tCurrentLocation];
}
#pragma mark - Caller Methods For Data
-(void)getCurrentLocation{
    
    NSString* fql1 = [NSString stringWithFormat:
                      @"SELECT name,uid, current_location.name, current_location.id FROM user WHERE  uid IN (SELECT uid2 FROM friend WHERE uid1= me()) AND current_location>0 ORDER BY current_location DESC"];
    
    NSString* fql2 = [NSString stringWithFormat:
                      @"SELECT location.latitude,location.longitude,page_id FROM page WHERE page_id IN (SELECT current_location FROM #friends)"];
    NSString* fqlC = [NSString stringWithFormat:
                      @"{\"friends\":\"%@\",\"location\":\"%@\"}",fql1,fql2];
    NSDictionary *response = [self doMultiQuery:fqlC];  
    [self parseCityAndPeople:response andType:@"current_location"];
    
}
-(void)getHometownLocation{

    NSString* fqlH1 = [NSString stringWithFormat:
                       @"SELECT name,uid, hometown_location.name, hometown_location.id FROM user WHERE  uid IN (SELECT uid2 FROM friend WHERE uid1= me()) AND hometown_location>0 ORDER BY hometown_location DESC "];
    
    NSString* fqlH2 = [NSString stringWithFormat:
                       @"SELECT location.latitude,location.longitude,name,page_id FROM page WHERE page_id IN (SELECT hometown_location FROM #friends)"];
    NSString* fqlH = [NSString stringWithFormat:
                      @"{\"friends\":\"%@\",\"location\":\"%@\"}",fqlH1,fqlH2];
    NSDictionary *response = [self doMultiQuery:fqlH];  
    [self parseCityAndPeople:response andType:@"hometown_location"];    
    
}
-(void)getEducationInfo{
    NSString* fqlE1 = [NSString stringWithFormat:
                       @"SELECT name, uid, education FROM user WHERE  uid IN (SELECT uid2 FROM friend WHERE uid1= me())"];
    NSString* fqlE2 = [NSString stringWithFormat:
                       @"SELECT location,name,page_id FROM page WHERE page_id IN (SELECT education FROM #friendsEdu)"];
    NSString* fqlE = [NSString stringWithFormat:
                      @"{\"friendsEdu\":\"%@\",\"schoolLocation\":\"%@\"}",fqlE1,fqlE2];
    NSDictionary *response = [self doMultiQuery:fqlE];  
    [self parseCityAndPeople:response andType:@"education"];  
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
