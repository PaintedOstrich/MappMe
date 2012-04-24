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
#import "SettingsMenuController.h"
#import <QuartzCore/QuartzCore.h>

@implementation MainViewController{
    DataManagerSingleton * mainDataManager;
    MBProgressHUD *HUD;
    NSMutableArray * annotations;
    locTypeEnum currDisplayedType;
    IBOutlet UIButton * cameraBtn;
    IBOutlet UIButton * locationTypeBtn;
    BOOL isFriendAnnotationType;
    IBOutlet UIView* progressIndicator;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [_mapView setDelegate:self];
    annotations = [[NSMutableArray alloc]initWithCapacity:80];
    mainDataManager = [DataManagerSingleton sharedManager];
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    [[CoordinateLookupManager sharedManager] setDelegate:self];

    // Show the HUD while the provided method executes in a new thread
    [HUD showWhileExecuting:@selector(fetchAndProcess) onTarget:self withObject:nil animated:YES];
}

-(void) viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:TRUE animated:TRUE];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _mapView = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Screen Layout Methods

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self layoutForInterfaceOrientation:toInterfaceOrientation];
}

-(void) layoutForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //Only show camera button when it is in landscape
    [cameraBtn setHidden:UIInterfaceOrientationIsPortrait(interfaceOrientation)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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

-(IBAction)pushSearchController{
    [self performSegueWithIdentifier:@"searchview" sender:self];
}

#pragma mark - Modal Popup Methods
//Adds subview of menu selection for current location, hometown, high school, etc.
-(IBAction)showLocationMenu{
    LocTypeMenuController *controller = [[LocTypeMenuController alloc] initWithNibName:@"LocTypeMenuController" bundle:nil];
    controller.delegate = self;
    controller.selectedLocType = currDisplayedType;
    [controller presentInParentViewController:self];
}

-(IBAction)showSettingsMenu{
    SettingsMenuController *controller = [[SettingsMenuController alloc] initWithNibName:@"SettingsMenuController" bundle:nil];
    //controller.delegate = self;
    //controller.selectedLocType = currDisplayedType;
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
    FacebookDataHandler *fbDataHandler = [FacebookDataHandler sharedInstance];
    /*Call Methods for info*/
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
    [self.navigationController popToViewController:self animated:YES];
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

#pragma mark - CoodinateLookUpManager Delegate methods
-(void) allOperationFinished
{
    [self performSelectorOnMainThread:@selector(dissmissLoadingView) withObject:nil waitUntilDone:NO];
}
-(void) dissmissLoadingView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:2];
    [progressIndicator setTransform:CGAffineTransformMakeTranslation(0, 110.0)];
    [UIView commitAnimations];
}

#pragma mark - Screen shot methods
-(IBAction)takeScreenShot:(UIButton*)sender
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Sorry"
                          message: @"Under Construction"
                          delegate: nil
                          cancelButtonTitle:@"Oh Can't Wait!"
                          otherButtonTitles:nil];
    [alert show];
}

@end
