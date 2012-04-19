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

@implementation MainViewController{
    DataManagerSingleton * mainDataManager;
    MBProgressHUD *HUD;
    NSMutableArray * annotations;
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
    [_mapView setDelegate:self];
    annotations = [[NSMutableArray alloc]initWithCapacity:20];
    mainDataManager = [DataManagerSingleton sharedManager];
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    
    //Set Bools for view methods
    displayTypeContainerIsShown = FALSE;
    
    //[self addLoadView];
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
    _mapView = nil;
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
        controller.selectedAnnotation = (MyAnnotation*)sender;
    } else if ([segue.identifier isEqualToString:@"showwebview"]){
        NSString *fId = [(Person*)sender uid];
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
- (void) showDetail:(UIButton*)btn {
    //This trick got back the annotation associtaed with the pinView we tapped.
    MyAnnotation* annotation = [annotations objectAtIndex:btn.tag];
    int count = [annotation.peopleArr count];
	if(count>1){
        [self performSegueWithIdentifier:@"showdetaillist" sender:annotation];
	}
	//only one person, go to the facebook page directly.!
	else {
        [self performSegueWithIdentifier:@"showwebview" sender:[annotation.peopleArr objectAtIndex:0]];
	}
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
//-(NSArray*) getFriendsInCity:(NSString*) cityName{
//    NSString * city_id = [mainDataManager.placeContainer getIdFromPlace:selectedCity];
//    
//    NSDictionary * currentGrouping = [mainDataManager.peopleContainer getCurrentGrouping];
//    return [[currentGrouping objectForKey:city_id] allObjects];
//}

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
-(void)makeAnnotations:(NSArray*)places forLocType:(locTypeEnum)locType {
    //Using class as wrapper to process instances of itself
    annotations = [[NSMutableArray alloc] initWithCapacity:[[mainDataManager peopleContainer] count]];
    for(int i=0; i < [places count]; i++) {
        Place* place = [places objectAtIndex:i];
        MyAnnotation* anno = [[MyAnnotation alloc] initWithPlace:place forLocType:locType];
        [annotations addObject:anno];
    }
}
-(void)getLocationsForFriend:(Person *)friend{  
//     annotations = [[NSMutableArray alloc] initWithCapacity:10];
//    [annotations addObjectsFromArray:[MyAnnotation getLocationsForFriend:friend]];
}
-(void)showPins
{
    [_mapView addAnnotations:annotations];
    [ZoomHelper zoomToFitAnnoations:_mapView];
}
-(void)clearMap{
    [_mapView removeAnnotations:annotations];
}

-(void) showCurrentLoc
{
    [self showLocationType:tCurrentLocation];
}

-(void) setBtnTitleForAllStates:(UIButton*)btn withText:(NSString*)txt 
{
    [btn setTitle:txt forState:UIControlStateNormal];
    [btn setTitle:txt forState:UIControlStateHighlighted];
    [btn setTitle:txt forState:UIControlStateDisabled];
    [btn setTitle:txt forState:UIControlStateSelected];
}

-(void)showLocationType:(locTypeEnum)locType{
    [self closeLocationMenu];
    [self clearMap];
    currDisplayedType = locType;
    isFriendAnnotationType = FALSE;
    [self setBtnTitleForAllStates:locationTypeBtn withText:[LocationTypeEnum getNameFromEnum:currDisplayedType]];
    
    NSArray* relevantPlaces = [mainDataManager.placeContainer getPlacesUsedAs:locType];
    [self makeAnnotations:relevantPlaces forLocType:locType];
    [self showPins];
}

#pragma mark - main data processing dispatch
- (void)fetchAndProcess {
    Timer * t = [[Timer alloc] init];
    /*Call Methods for info*/
    FacebookDataHandler *fbDataHandler = [[FacebookDataHandler alloc] init];
    //[fbDataHandler setProgressUpdaterDelegate:self];
    [fbDataHandler getHometownLocation];
    [fbDataHandler getEducationInfo];
    [fbDataHandler getCurrentLocation];

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


-(UIImage*) getPinImage:(MyAnnotation*)annotation
{
    //If we're showing all location types for a friend
    NSString* imgName;
    if (isFriendAnnotationType) {
      imgName = @"bluePin1.25.png";
    } else {
        int count = [annotation.peopleArr count];
        if(count > 25){
            imgName = @"redPin.png";
        } else if(count > 15) {
            imgName = @"orangePin.png";
        } else if(count > 10) {
            imgName = @"yellowPin.png";
        } else if(count > 5) {
            imgName = @"yellow-greenPin.png";
        } else if(count > 3) {
            imgName = @"greenPin.png";
        } else if(count > 1) {
            imgName = @"tealPin.png";
        } else {
            imgName = @"bluePin.png";
        }   
    }

    return [UIImage imageNamed:imgName];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MyAnnotation *)annotation
{
	// if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
	// try to dequeue an existing pin view first
	static NSString* identifier = @"AnnotationIdentifier";
    
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        //annotationView.animatesDrop = YES;
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:self action:@selector(showDetail:) forControlEvents:UIControlEventTouchUpInside];
        annotationView.rightCalloutAccessoryView = rightButton;
    } else {
        annotationView.annotation = annotation;
    }
    
    annotationView.image = [self getPinImage:annotation ];
    
    UIImageView *profileIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile.png"]];
    if (annotation.person_id !=nil) {
        Person* friend = [[mainDataManager peopleContainer] get:annotation.person_id];
        [profileIconView setImageWithURL:[NSURL URLWithString:friend.profileUrl] placeholderImage:[UIImage imageNamed:@"profile.png"]];
    }
    annotationView.leftCalloutAccessoryView = profileIconView;
    
    UIButton *button = (UIButton *)annotationView.rightCalloutAccessoryView;
    button.tag = [annotations indexOfObject:(MyAnnotation *)annotation];
    
    return annotationView;
}

#pragma mark - FriendSearchViewControllerDelegate methods
- (void)didSelectFriend:(NSString *)uid {
//    [self.navigationController popViewControllerAnimated:TRUE];
//    [self clearMap];
//    isFriendAnnotationType = TRUE;
//    Person* friend = [mainDataManager.peopleContainer get:uid];
//    [self getLocationsForFriend: friend];
//    [self showPins];
//    NSString * buttonLabel= friend.name;
//    [locationTypeBtn setTitle:buttonLabel forState:UIControlStateNormal];
//    [locationTypeBtn setTitle:buttonLabel forState:UIControlStateHighlighted];
//    [locationTypeBtn setTitle:buttonLabel forState:UIControlStateDisabled];
//    [locationTypeBtn setTitle:buttonLabel forState:UIControlStateSelected];
}

@end
