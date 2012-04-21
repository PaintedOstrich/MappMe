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
#import "PersonMenuViewController.h"
#import "FriendSearchViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation MainViewController{
    DataManagerSingleton * mainDataManager;
    MBProgressHUD *HUD;
    NSMutableArray * annotations;
    locTypeEnum currDisplayedType;
    //Display private variables
    UIButton * locationTypeBtn;
    UIView *loadScreenContainer;
    UIView *loadInfoContainer;
    UIProgressView *loadScreenProgressBar;
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
//        personmenusegue
    } else if ([segue.identifier isEqualToString:@"personmenusegue"]){
        Person *friend = (Person*)sender;
        PersonMenuViewController *controller = segue.destinationViewController;
        controller.person = friend;
    } else if ([segue.identifier isEqualToString:@"searchview"]){
//        FriendSearchViewController* controller = segue.destinationViewController;
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
        [self performSegueWithIdentifier:@"personmenusegue" sender:[annotation.peopleArr objectAtIndex:0]];
	}
}

-(void)pushSearchController{
    [self performSegueWithIdentifier:@"searchview" sender:self];
}
-(void)pushSettingsController{
    [self performSegueWithIdentifier:@"settingsview" sender:self];
}

#pragma mark - Custom Loading View and Logic
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
        //[self disableEduButtons];
    } 
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
-(void)setImagesForButton{
    //Will finish once merged
    UIButton* loginButton;
    UIImage *loginImage = [UIImage imageNamed:@"LoginWithFacebookNormal@2x.png"];
    UIImage *stretchableButtonImage = [loginImage stretchableImageWithLeftCapWidth:0 topCapHeight:0]; 
    [loginButton setBackgroundImage:stretchableButtonImage forState:UIControlStateNormal];
    UIImage *loginImagePressed = [UIImage imageNamed:@"LoginWithFacebookPressed@2x.png"];
    UIImage *stretchableButtonImagePress = [loginImagePressed stretchableImageWithLeftCapWidth:0 topCapHeight:0]; 
    [loginButton setBackgroundImage:stretchableButtonImagePress forState:UIControlStateHighlighted];
}

//Adds subview of menu selection for current location, hometown, high school, etc.
-(void)showLocationMenu{
    LocTypeMenuController *controller = [[LocTypeMenuController alloc] initWithNibName:@"LocTypeMenuController" bundle:nil];
    controller.delegate = self;
    controller.selectedLocType = currDisplayedType;
    [controller presentInParentViewController:self];
}


#pragma mark - Map pins methods

//Generate MyAnnotation objects depending on the array of places and the locType passed along
//Also add the generated annotation into annotations array immediately.
-(void)makeAnnotations:(NSArray*)places forLocType:(locTypeEnum)locType {
    for(int i=0; i < [places count]; i++) {
        Place* place = [places objectAtIndex:i];
        MyAnnotation* anno = [[MyAnnotation alloc] initWithPlace:place forLocType:locType];
        if ([anno hasValidCoordinate]) {
            [annotations addObject:anno];
        }
    }
}

//Make annotations for a particular person.
//Such annotations will have title as place name and subtitle as the type of place(e.g. HomeTown/College etc.).
-(void)makeAnnotationsForPerson:(Person*)person {
    NSDictionary* mapping = [person getPlacesMapping];
    NSEnumerator *enumerator = [mapping keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        locTypeEnum locType = [key intValue];
        NSArray* places = [mapping objectForKey:key];
        for(int j=0; j < [places count]; j++) {
            Place* place = [places objectAtIndex:j];
            MyAnnotation* anno = [[MyAnnotation alloc] initWithPlace:place forPerson:person forLocType:locType];
            if ([anno hasValidCoordinate]) {
                [annotations addObject:anno];
            }
        }
    }
}

-(void)showPins
{
    [_mapView addAnnotations:annotations];
    [ZoomHelper zoomToFitAnnoations:_mapView];
}
//Clear the map of pins. Also clear annotations array.
-(void)clearMap{
    [_mapView removeAnnotations:annotations];
    [annotations removeAllObjects];
}

-(void) setBtnTitleForAllStates:(UIButton*)btn withText:(NSString*)txt 
{
    [btn setTitle:txt forState:UIControlStateNormal];
    [btn setTitle:txt forState:UIControlStateHighlighted];
    [btn setTitle:txt forState:UIControlStateDisabled];
    [btn setTitle:txt forState:UIControlStateSelected];
}

-(void) showCurrentLoc
{
    [self showLocationType:tCurrentLocation];
}

-(void)showLocationType:(locTypeEnum)locType{
   // [self closeLocationMenu];
    [self clearMap];
    currDisplayedType = locType;
    isFriendAnnotationType = FALSE;
    [self setBtnTitleForAllStates:locationTypeBtn withText:[LocationTypeEnum getNameFromEnum:currDisplayedType]];
    
    NSArray* relevantPlaces = [mainDataManager.placeContainer getPlacesUsedAs:locType];

    //DebugLog(@"Showing %@, has %d entries", [LocationTypeEnum getNameFromEnum:locType], [relevantPlaces count]);
    [self makeAnnotations:relevantPlaces forLocType:locType];
    [self showPins];
}

#pragma mark - main data processing dispatch
- (void)fetchAndProcess {
    Timer * t = [[Timer alloc] init];
    /*Call Methods for info*/
    FacebookDataHandler *fbDataHandler = [[FacebookDataHandler alloc] init];
    [fbDataHandler setProgressUpdaterDelegate:self];
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
        if (annotation.locType == tCurrentLocation) {
            imgName = @"currentlocation.png";
        } else if(annotation.locType == tHomeTown) {
            imgName = @"hometown.png";
        } else if(annotation.locType==tCollege){
            imgName = @"college.png";
        } else if(annotation.locType==tHighSchool){
            imgName = @"highschool.png";
        } else {
            imgName = @"question.png";
        }
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
	NSString* identifier;
    if (isFriendAnnotationType) {
        identifier = @"PersonAnnotation";
    } else {
        identifier = @"NormalAnnotation";
    }

    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        //annotationView.animatesDrop = YES;
        if (!isFriendAnnotationType) {
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:@selector(showDetail:) forControlEvents:UIControlEventTouchUpInside];
            annotationView.rightCalloutAccessoryView = rightButton;
            //rightButton.tag = [annotations indexOfObject:(MyAnnotation *)annotation];
        }
    } else {
        annotationView.annotation = annotation;
    }
    
    annotationView.image = [self getPinImage:annotation ];
    
    if (!isFriendAnnotationType) {
        annotationView.rightCalloutAccessoryView.tag = [annotations indexOfObject:(MyAnnotation *)annotation];
        UIImageView *profileIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:annotation.placeHolderImg]];
        if (annotation.person_id !=nil) {
            Person* friend = [[mainDataManager peopleContainer] get:annotation.person_id];
            [profileIconView setImageWithURL:[NSURL URLWithString:friend.profileUrl] placeholderImage:[UIImage imageNamed:annotation.placeHolderImg]];
        }
        annotationView.leftCalloutAccessoryView = profileIconView;   
    }
    
    return annotationView;
}
//THIS Method not working.
#pragma mark - FriendSearchViewControllerDelegate methods
- (void)didSelectFriend:(Person *)selectedPerson {
    [self.navigationController popViewControllerAnimated:TRUE];
    [self clearMap];
    isFriendAnnotationType = TRUE;
    currDisplayedType = tNilLocType;
    [self makeAnnotationsForPerson:selectedPerson];
    [self showPins];
    [self setBtnTitleForAllStates:locationTypeBtn withText:selectedPerson.name];
}

#pragma mark - LocTypeMenuController Delegate methods
-(void) disSelectLocType:(locTypeEnum)locType
{
    [self showLocationType:locType];
}

@end
