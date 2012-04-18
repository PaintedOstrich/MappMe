/*
 * The main view controller of the app.
 * It is responsible for fetching data from facebook. Creating annotations and
 * addig these annotations to map view with animation.
 */

#import "MainViewController.h"
#import "DebugLog.h"
#import "Timer.h"
#import "MyAnnotation.h"
#import "WebViewController.h"
#import "ListViewController.h"
#import "FacebookDataHandler.h"
#import "ZoomHelper.h"
#import "DataManagerSingleton.h"
#import "UIImageView+AFNetworking.h"

#import <QuartzCore/QuartzCore.h>

@interface MainViewController()

-(void)showPins;
/*View Change Methods*/
-(void)showLocationType:(locTypeEnum)locType;
-(void)showHometown;
-(void)showCurrentLoc;
-(void)showHighSchool;
-(void)showCollege;
-(void)showGrad;

-(void)addLoadView;
-(void)updateProgressBar:(float)progressAmount;
-(void)showLocationMenu;
@end


@implementation MainViewController{
    DataManagerSingleton * mainDataManager;
    MBProgressHUD *HUD;
    NSMutableArray * annotations;
    NSString *selectedCity;
    NSString *selectedPerson;
    locTypeEnum currDisplayedType;
    
    //Display private variables
    UIButton * locationTypeBtn;
    UIView *displayTypeContainer;
    UIView *personSearchContainer;
    UIView *loadScreenContainer;
    UIView *loadInfoContainer;
    UIProgressView *loadScreenProgressBar;
    BOOL displayTypeContainerIsShown;
    BOOL isFriendAnnotationType;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [mapView setDelegate:self];
    annotations = [[NSMutableArray alloc]initWithCapacity:20];
    mainDataManager = [DataManagerSingleton sharedManager];
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    
    //Set Bools for view methods
    displayTypeContainerIsShown = FALSE;
    
    [self addLoadView];
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
    mapView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - Transition Functions
//All functions involving transition to another screen should go below

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"showdetaillist"]) {
        ListViewController *controller = segue.destinationViewController;
        controller.selectedCity = selectedCity;
    } else if ([segue.identifier isEqualToString:@"showwebview"]){
        NSString *fId =[mainDataManager.peopleContainer getIdFromName:selectedPerson];
		NSString *urlStr = [[NSString alloc] initWithFormat:@"%@%@",@"http://m.facebook.com/profile.php?id=",fId];
		NSURL *url =[[NSURL alloc] initWithString:urlStr];
        WebViewController *controller = segue.destinationViewController;
        controller.url = url;
    } else if ([segue.identifier isEqualToString:@"searchview"]){
        FriendSearchViewController* controller = segue.destinationViewController;
        controller.searchDelegate = self;
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
    NSString * city_id = [mainDataManager.placeContainer getIdFromPlace:selectedCity];

    NSDictionary * currentGrouping = [mainDataManager.peopleContainer getCurrentGrouping];
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

#pragma mark - Methods to put pins when location type is changed

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

#pragma mark - Custom Loading View and Logic
-(void)pushSearchController{
    DebugLog(@"changing to search controller");
    [self performSegueWithIdentifier:@"searchview" sender:self];
//    [self presentModalViewController: animated:YES]
}
-(void)pushSettingsController{
    [self performSegueWithIdentifier:@"settingsview" sender:self];
}
-(void)addBottomNavView{
    UIView *navContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 540, 320, 44)];
//    [navContainer setAlpha:0.0];                                                   
    
    locationTypeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    locationTypeBtn.frame = CGRectMake(9, 7, 98, 37);
    [locationTypeBtn setTitle:@"Current Location" forState:UIControlStateNormal];
    locationTypeBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [locationTypeBtn addTarget:self action:@selector(showLocationMenu) forControlEvents:UIControlEventTouchDown];
    [navContainer addSubview:locationTypeBtn];

    UIButton *search = [UIButton buttonWithType:UIButtonTypeCustom];
    search.contentMode = UIViewContentModeScaleToFill;
    [search setBackgroundImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    [search addTarget:self action:@selector(pushSearchController) forControlEvents:UIControlEventTouchUpInside];
    search.frame = CGRectMake(110, 7.0, 42.0, 37.0);//width and height should be same value
    search.layer.cornerRadius = 25;//half of the width
    [navContainer addSubview:search];
    
    UIButton *settings = [UIButton buttonWithType:UIButtonTypeCustom];
    settings.contentMode = UIViewContentModeScaleToFill;
    [settings setBackgroundImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
    [settings addTarget:self action:@selector(pushSettingsController) forControlEvents:UIControlEventTouchUpInside];
    settings.frame = CGRectMake(284, 7.0, 29.0, 31.0);//width and height should be same value
    settings.layer.cornerRadius = 25;//half of the width
    [navContainer addSubview:settings];
    
    [self.view addSubview:navContainer];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:2];
    [navContainer setTransform:CGAffineTransformMakeTranslation(0, -110.0)];
//    [navContainer setAlpha:1.0];
    [UIView commitAnimations];
}
-(void)addLoadView{
    //Create main view container
    loadScreenContainer = [[UIView alloc] initWithFrame:CGRectMake(0, -20, 320, 80)];
    [loadScreenContainer setAlpha:0.0];
    //Create Progress Bar and Progress container
    UIView *progessScreenContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 48)];
    loadScreenProgressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    loadScreenProgressBar.frame = CGRectMake(160, 25, 155, 30);
    [progessScreenContainer addSubview:loadScreenProgressBar];

    //Create and add loading label
    UILabel* loading = [[UILabel alloc]initWithFrame:CGRectMake(5,10,155,30)];
    loading.adjustsFontSizeToFitWidth=YES;
    loading.text=@" Loading Friends and Places: ";
    [loading setFont:[UIFont boldSystemFontOfSize:26]];
    loading.textColor=[UIColor whiteColor];
    loading.backgroundColor =[UIColor clearColor];
    [progessScreenContainer addSubview:loading];
    //Add Progress Container to View
    [loadScreenContainer addSubview:progessScreenContainer];
    
    //Create and add info label
    loadInfoContainer = [[UIView alloc] initWithFrame:CGRectMake(80, 42, 160, 86)];
    //Add Arrow Image
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(60, 17, 40, 21)];
    arrow.image = [UIImage imageNamed:@"triangle.png"];
    [loadInfoContainer addSubview:arrow];
    UILabel* info = [[UILabel alloc]initWithFrame:CGRectMake(0,0,160,23)];
    info.adjustsFontSizeToFitWidth=YES;
    info.text=@"  Showing Current Location  ";
    [info setFont:[UIFont boldSystemFontOfSize:20]];
    //round corners
    CALayer *infoLayer = info.layer;
    [infoLayer setMasksToBounds:YES];
    [infoLayer setCornerRadius:5.0f];
    [infoLayer setBorderWidth:2.0f];
    [infoLayer setBorderColor: [[UIColor blackColor] CGColor]];
    [infoLayer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [loadInfoContainer addSubview:info];

    [loadScreenContainer addSubview:loadInfoContainer];
    
    //Rounded Container Corners
    CALayer *dtc = progessScreenContainer.layer;
    [dtc setMasksToBounds:YES];
    [dtc setCornerRadius:8.0f];
    [dtc setBorderWidth:2.0f];
    [dtc setBorderColor: [[UIColor blackColor] CGColor]];
    [dtc setBackgroundColor: [[UIColor blackColor] CGColor]];

    [self.view addSubview:loadScreenContainer];
    [UIView beginAnimations:nil context:nil];
    [loadScreenContainer setAlpha:1.0];
    [UIView commitAnimations];
}
-(void)hideLoadScreen{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.45];
    [loadScreenContainer setTransform:CGAffineTransformMakeTranslation(0, -100.0)];
    [UIView commitAnimations];
}
#pragma mark - disable/enable Edu buttons
-(void)enableEduButtons{
    
}
-(void)disableEduButtons{
    
}
#pragma mark - progress bar delegate methods
-(void)finishedLoading{
    DebugLog(@"called finished loading");
    [self hideLoadScreen];

    //Calling this removes animation...?
//    [loadScreenContainer removeFromSuperview];
}
-(void)showDisplayMenu{
    [self addBottomNavView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [loadInfoContainer setAlpha:0.0];
    [UIView commitAnimations];
}
- (void)updateProgressBar:(float)progressAmount{

    //How to avoid updating this if object is nil;
//    DebugLog(@"main controller update progress bar called with amount :%f",progressAmount);
    if (loadScreenProgressBar==nil) {
        DebugLog(@"WARNING: Trying to update nil progress bar");
    }else{
        [loadScreenProgressBar setProgress:progressAmount animated:YES];
        //Disable Edu Buttons until finished loading
        [self disableEduButtons];
    } 
}
#pragma mark - Custom Person Search 
-(NSArray*) getFriendsInCity:(NSString*) cityName{
    NSString * city_id = [mainDataManager.placeContainer getIdFromPlace:selectedCity];
    
    NSDictionary * currentGrouping = [mainDataManager.peopleContainer getCurrentGrouping];
    return [[currentGrouping objectForKey:city_id] allObjects];
}

#pragma mark - Custom View Methods
//Helper method to create buttons for the location type menu (Used in showLocationMenu)
-(UIButton*) createMenuButton:(NSString*)title yCordinate:(CGFloat)yCor locType: (locTypeEnum) locType {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.frame = CGRectMake(30.0, yCor, 180.0, 40.0);
    btn.highlighted = (locType == currDisplayedType);
    btn.enabled = (locType != currDisplayedType);
    return btn;
}

//Create a round close button to be used in location type menu
-(UIButton*) createCloseBtn {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.contentMode = UIViewContentModeScaleToFill;
    [button setBackgroundImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeLocationMenu) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(205, -15.0, 50.0, 50.0);//width and height should be same value
    button.layer.cornerRadius = 25;//half of the width
    return button;
}

-(void) closeLocationMenu {
    if(displayTypeContainerIsShown){
      [displayTypeContainer removeFromSuperview];
      displayTypeContainerIsShown = FALSE;
    }
}

//Adds subview of menu selection for current location, hometown, high school, etc.
-(void)showLocationMenu{
    //Don't add subview twice
    if(displayTypeContainerIsShown){
        return;
    }
    displayTypeContainerIsShown = TRUE;
    
    displayTypeContainer = [[UIView alloc] initWithFrame:CGRectMake(40, 90, 240, 280)];
    [displayTypeContainer setAlpha:0.0];
    [displayTypeContainer.layer setBackgroundColor:[[UIColor clearColor] CGColor]];
    
    
    UIView *displayTypeView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 280)];
    [displayTypeView setAlpha:0.65];
    [displayTypeContainer addSubview:displayTypeView];
    
    [displayTypeContainer addSubview:[self createCloseBtn]];
    
    /*Navigation Buttons*/
    UIButton *curButton = [self createMenuButton:@"Current Location" yCordinate:20 locType:tCurrentLocation];
    [curButton addTarget:self action:@selector(showCurrentLoc) forControlEvents:UIControlEventTouchDown];
    [displayTypeContainer addSubview:curButton];
    
    UIButton *homeButton = [self createMenuButton:@"Hometown" yCordinate:70 locType:tHomeTown];
    [homeButton addTarget:self  action:@selector(showHometown) forControlEvents:UIControlEventTouchDown];
    [displayTypeContainer addSubview:homeButton];
    
    UIButton *highButton = [self createMenuButton:@"High School" yCordinate:120 locType:tHighSchool];
    [highButton addTarget:self  action:@selector(showHighSchool) forControlEvents:UIControlEventTouchDown];
    [displayTypeContainer addSubview:highButton];

    UIButton *collButton = [self createMenuButton:@"College" yCordinate:170 locType:tCollege];
    [collButton addTarget:self  action:@selector(showCollege) forControlEvents:UIControlEventTouchDown];
    [displayTypeContainer addSubview:collButton];

    UIButton *gradButton = [self createMenuButton:@"Graduate School" yCordinate:220 locType:tGradSchool];
    [gradButton addTarget:self  action:@selector(showGrad) forControlEvents:UIControlEventTouchDown];
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


#pragma mark - Map pins methods
-(void)makeAnnotationFromDict:(NSDictionary*)groupings{
    //Using class as wrapper to process instances of itself
    annotations = [[NSMutableArray alloc] initWithCapacity:[[mainDataManager peopleContainer] getNumPeople]];
    NSArray* annotationItems = [MyAnnotation makeAnnotationFromDict:groupings]; 
    [annotations addObjectsFromArray:annotationItems];
}
-(void)getLocationsForFriend:(Friend *)friend{  
     annotations = [[NSMutableArray alloc] initWithCapacity:10];
    [annotations addObjectsFromArray:[MyAnnotation getLocationsForFriend:friend]];
}
-(void)showPins
{
    [mapView addAnnotations:annotations];
    [ZoomHelper zoomToFitAnnoations:mapView];
}
-(void)clearMap{
    [mapView removeAnnotations:annotations];
}
-(void)showLocationType:(locTypeEnum)locType{
    //[[mainDataManager peopleContainer] printGroupings:locType];
    [self closeLocationMenu];
    [self clearMap];
    currDisplayedType = locType;
    isFriendAnnotationType = FALSE;
    NSString * buttonLabel= [LocationTypeEnum getNameFromEnum:currDisplayedType];
    [locationTypeBtn setTitle:buttonLabel forState:UIControlStateNormal];
    [locationTypeBtn setTitle:buttonLabel forState:UIControlStateHighlighted];
    [locationTypeBtn setTitle:buttonLabel forState:UIControlStateDisabled];
    [locationTypeBtn setTitle:buttonLabel forState:UIControlStateSelected];
    switch(locType){
        case tHomeTown:
            [self makeAnnotationFromDict:[mainDataManager.peopleContainer getAndSetFriendGroupingForLocType:tHomeTown]];
            break;
        case tCurrentLocation:
            [self makeAnnotationFromDict:[mainDataManager.peopleContainer getAndSetFriendGroupingForLocType:tCurrentLocation]];
            break;
        case tHighSchool:
            [self makeAnnotationFromDict:[mainDataManager.peopleContainer getAndSetFriendGroupingForLocType:tHighSchool]];
            break;
        case tCollege:
            [self makeAnnotationFromDict:[mainDataManager.peopleContainer getAndSetFriendGroupingForLocType:tCollege]];
            break;
        case tGradSchool:
            [self makeAnnotationFromDict:[mainDataManager.peopleContainer getAndSetFriendGroupingForLocType:tGradSchool]];
            break;
        case tWork:
           [self makeAnnotationFromDict:[mainDataManager.peopleContainer getAndSetFriendGroupingForLocType:tWork]];
            break;
        default:
            DebugLog(@"Warning: hitting default case");
    }
    [self showPins];
}

#pragma mark - main data processing dispatch
- (void)fetchAndProcess {
    Timer * t = [[Timer alloc] init];
    /*Call Methods for info*/
    FacebookDataHandler *fbDataHandler = [[FacebookDataHandler alloc] init];
    [fbDataHandler setProgressUpdaterDelegate:self];
    [fbDataHandler getCurrentLocation];
    [fbDataHandler getHometownLocation];
    [fbDataHandler getEducationInfo];

    [self performSelectorOnMainThread:@selector(showCurrentLoc) withObject:nil waitUntilDone:NO];
    int time = [t endTimerAndGetTotalTime];
    DebugLog(@"Total App Loadtime: %i",time);
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
    
    MKAnnotationView* pinView = [[MKPinAnnotationView alloc]
                                 initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
    pinView.canShowCallout=YES;
    //check for different type of pin (sizes)
    
    pinView.rightCalloutAccessoryView = rightButton;
    pinView.image = [MyAnnotation getPinImage:annotation.type isFriendLocationType:isFriendAnnotationType];

    //  pinView.tag = @"moreThanOnePerson";
    
    UIImageView *profileIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile.png"]];
    if (annotation.user_id !=nil) {
        Friend* friend = [[mainDataManager peopleContainer] getFriendFromId:annotation.user_id];
        [profileIconView setImageWithURL:[NSURL URLWithString:friend.profileUrl] placeholderImage:[UIImage imageNamed:@"profile.png"]];
    }
    pinView.leftCalloutAccessoryView = profileIconView;
    return pinView;
}

#pragma mark - FriendSearchViewControllerDelegate methods
- (void)didSelectFriend:(NSString *)uid {
    [self.navigationController popViewControllerAnimated:TRUE];
    [self clearMap];
    isFriendAnnotationType = TRUE;
    Friend* friend = [mainDataManager.peopleContainer getFriendFromId:uid];
    [self getLocationsForFriend: friend];
    [self showPins];
    NSString * buttonLabel= friend.name;
    [locationTypeBtn setTitle:buttonLabel forState:UIControlStateNormal];
    [locationTypeBtn setTitle:buttonLabel forState:UIControlStateHighlighted];
    [locationTypeBtn setTitle:buttonLabel forState:UIControlStateDisabled];
    [locationTypeBtn setTitle:buttonLabel forState:UIControlStateSelected];
}

@end
