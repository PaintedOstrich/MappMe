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
#import "ScreenShotController.h"
#import "AbstractSlidingContainer.h"
#import "SlidingContainer.h"
#import "FriendSearchViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation MainViewController{
    DataManagerSingleton * mainDataManager;
    MBProgressHUD *HUD;
    NSMutableArray * annotations;
    locTypeEnum currDisplayedType;
    IBOutlet UIButton * cameraBtn;
    IBOutlet UIButton * locationTypeBtn;
    IBOutlet UIButton * settingsBtn;
    IBOutlet UIButton * searchBtn;
    //Used to do transform animation to buy us time......
    IBOutlet UIButton * hiddenBtn;
    
    //These two private variables used to keep track of whether we are showing mutualFriends or all  Friends
    BOOL isMutualFriendType;
    Person *mutualFriendsWith;
    
    //This used for determining which set of map annotations to use
    BOOL isFriendAnnotationType;
    
    IBOutlet UIView* progressIndicator;
    BOOL _finishedSaving;
    BOOL _startedOperations;
    
    //Main Sliding Controller
    SlidingContainer *_slidingController;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    //Places is not saved to disk
    //We use this flag to make sure saving function is only invoked once
    //so if places are saved to disk once already during this user session.
    //_fisnishedSaving will be TRUE.
    _finishedSaving = FALSE;
    _startedOperations = FALSE;

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
    
    [self showMenuForLocations];
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
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        [cameraBtn setAlpha:0.0f];
    } else {
        [UIView animateWithDuration:0.5 animations:^
         {
             [cameraBtn setAlpha:1.0f];
             cameraBtn.transform = CGAffineTransformMakeScale(1.6f, 1.6f);
         }
                         completion:^(BOOL finished)
         {
             [UIView animateWithDuration:0.5 animations:^
              {
                  cameraBtn.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
              }];
         }];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
    //Upside down is the same as right side up, otherwise view gets stuck in horizontal when upside down
    //return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Transition Functions
//All functions involving transition to another screen should go below
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Check that main menu is closed
    [_slidingController closeMenu];
    if ([segue.identifier isEqualToString:@"showdetaillist"]) {
        ListViewController *controller = segue.destinationViewController;
        controller.selectedAnnotation = (MyAnnotation*)sender;
        controller.mvc= self;
//        personmenusegue
    } else if ([segue.identifier isEqualToString:@"personmenusegue"]){
        Person *friend = (Person*)sender;
        PersonMenuViewController *controller = segue.destinationViewController;
        controller.person = friend;
    } else if ([segue.identifier isEqualToString:@"searchview"]){
        FriendSearchViewController *controller = segue.destinationViewController;
        controller.mvc = self;
    }
} 


/*
 * This method is invoked when the accesory button on annotation view is tapped.
 * Takes the user into a list of friends or the friend's facebook page directly
 */
- (void) showFriendGroupDetail:(UIButton*)btn {
    //This trick got back the annotation associtaed with the pinView we tapped.
    MyAnnotation* annotation = [annotations objectAtIndex:btn.tag];
    int count = [annotation.peopleArr count];
	if(count>1){
        [self performSegueWithIdentifier:@"showdetaillist" sender:annotation];
	}
	//only one person, go to the facebook page directly.!
	else {
        [self didSelectFriend:[annotation.peopleArr objectAtIndex:0]];
        Person *person = [annotation.peopleArr objectAtIndex:0];
        [_slidingController showFriendMenu:person];
//        [self performSegueWithIdentifier:@"personmenusegue" sender:[annotation.peopleArr objectAtIndex:0]];
	}
}
//FIXME: Change to go to different menu with person options and location options
- (void) showLocationDetail:(UIButton*)btn {
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

#pragma mark - Sliding Interface
-(void)showMenuForLocations{
    _slidingController = [[SlidingContainer alloc] initWithNibName:@"AbstractSlider" bundle:nil];
    //controller.delegate = self;
    //controller.selectedLocType = currDisplayedType;
    [_slidingController presentInParentViewController:self];
}
-(void)updateMainLabel:(NSString*)label{
    [_slidingController updateMainLabel:label];
}
#pragma mark - Modal Popup Methods
//Adds subview of menu selection for current location, hometown, high school, etc.
-(IBAction)showLocationMenu{
    LocTypeMenuController *controller = [[LocTypeMenuController alloc] initWithNibName:@"LocTypeMenuController" bundle:nil];
//    controller.delegate = self;
    controller.selectedLocType = currDisplayedType;
    [controller presentInParentViewController:self];
}

-(IBAction)showSettingsMenu{
    SettingsMenuController *controller = [[SettingsMenuController alloc] initWithNibName:@"SettingsMenuController" bundle:nil];
    //controller.delegate = self;
    //controller.selectedLocType = currDisplayedType;
    [controller presentInParentViewController:self];
}

-(void) showScreeShotMenu:(UIImage*)screenShot
{
    ScreenShotController* controller = [[ScreenShotController alloc] initWithNibName:@"ScreenShotController" bundle:nil];

    [controller presentInParentViewController:self];
    [controller updateScreenShot:screenShot];
}

#pragma mark - Map pins methods

//Generate MyAnnotation objects depending on the array of places and the locType passed along
//Also add the generated annotation into annotations array immediately.
-(void)makeAnnotations:(NSArray*)places forLocType:(locTypeEnum)locType {
    for(int i=0; i < [places count]; i++) {
        Place* place = [places objectAtIndex:i];
        MyAnnotation* anno;
        if (isMutualFriendType) {
            anno = [[MyAnnotation alloc] initWithPlace:place forLocType:locType forMutualFriend:mutualFriendsWith];
        }else {
            anno = [[MyAnnotation alloc] initWithPlace:place forLocType:locType];
        }
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
    NSString * update =[[NSString alloc]initWithFormat:@"%@s",[LocationTypeEnum getNameFromEnum:currDisplayedType]];
    [_slidingController updateMainLabel:update];
    //[self setBtnTitleForAllStates:locationTypeBtn withText:[LocationTypeEnum getNameFromEnum:currDisplayedType]];
    
    NSArray* relevantPlaces;
    //This logic gets a list of mutual friends locations, or allfriends locations
    if (isMutualFriendType) {
        relevantPlaces = [mainDataManager.placeContainer getPlacesUsedAs:locType friendsWith:mutualFriendsWith];
    }else {
        relevantPlaces = [mainDataManager.placeContainer getPlacesUsedAs:locType];
    }

    //DebugLog(@"Showing %@, has %d entries", [LocationTypeEnum getNameFromEnum:locType], [relevantPlaces count]);
    [self makeAnnotations:relevantPlaces forLocType:locType];
    [self showPins];
}


#pragma mark - main data processing dispatch
- (void)fetchAndProcess {
    Timer * t = [[Timer alloc] init];
    //Load stored places from disk.
    [[mainDataManager placeContainer] loadPlacesFromDisk];
    FacebookDataHandler *fbDataHandler = [FacebookDataHandler sharedInstance];
    /*Call Methods for info*/
    [fbDataHandler getHometownLocation];
    [fbDataHandler getEducationInfo];
    [fbDataHandler getCurrentLocation];

    [self performSelectorOnMainThread:@selector(showCurrentLoc) withObject:nil waitUntilDone:NO];
    int time = [t endTimerAndGetTotalTime];
    DebugLog(@"Total App Loadtime: %i",time);
    [self performSelectorOnMainThread:@selector(bounceControls) withObject:nil waitUntilDone:NO];
}

#pragma mark - animation functions

-(void) bounceControls
{
    float duration = 0.5f;
    [UIView animateWithDuration:2.0f animations:^
     {
         //Wait for 3 seconds before starting animation proper.
         [self popAnimation:hiddenBtn];
     }  completion:^(BOOL finished)
     {
            [UIView animateWithDuration:duration animations:^
             {
                 [self popAnimation:locationTypeBtn];
             }
                             completion:^(BOOL finished)
             {
                 [UIView animateWithDuration:duration animations:^
                  {
                      [self shrinkAnimation:locationTypeBtn];
                  }
                                  completion:^(BOOL finished)
                  {
                      [UIView animateWithDuration:duration animations:^
                       {
                           [self popAnimation:searchBtn];
                       }
                                       completion:^(BOOL finished)
                       {
                           [UIView animateWithDuration:duration animations:^
                            {
                                [self shrinkAnimation:searchBtn];
                            }
                                            completion:^(BOOL finished)
                            {
                                [UIView animateWithDuration:duration animations:^
                                 {
                                     [self popAnimation:settingsBtn];
                                 }
                                                 completion:^(BOOL finished)
                                 {
                                     [UIView animateWithDuration:duration animations:^
                                      {
                                          [self shrinkAnimation:settingsBtn];
                                      }
                                                      completion:^(BOOL finished)
                                      {
                                          
                                      }];
                                 }];
                            }];
                       }];
                  }];
             }];
    }];
}

-(void) popAnimation:(UIButton*) btn
{
    float scale = 1.6f;
    [btn setAlpha:1.0f];
    btn.transform = CGAffineTransformMakeScale(scale, scale);
}

-(void) shrinkAnimation:(UIButton*) btn
{
    btn.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
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
            imgName = @"currentLocationPin.png";
        } else if(annotation.locType == tHomeTown) {
            imgName = @"hometownPin.png";
        } else if(annotation.locType==tCollege){
            imgName = @"collegePin.png";
        } else if(annotation.locType==tHighSchool){
            imgName = @"highSchoolPin.png";
        } else if(annotation.locType==tGradSchool){
            imgName = @"gradSchoolPin.png";
        } else if(annotation.locType==tHighSchool){
            imgName = @"workPin.png";
        }  
        else {
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
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        if (!isFriendAnnotationType) {
            [rightButton addTarget:self action:@selector(showFriendGroupDetail:) forControlEvents:UIControlEventTouchUpInside];
        } else{
            [rightButton addTarget:self action:@selector(showLocationDetail:) forControlEvents:UIControlEventTouchUpInside];
        }
        annotationView.rightCalloutAccessoryView = rightButton;
    } else {
        annotationView.annotation = annotation;
    }
    
    annotationView.image = [self getPinImage:annotation];
    
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
#pragma mark - DelegateMethods 
- (void)didSelectFriend:(Person *)selectedPerson {
    [self.navigationController popToViewController:self animated:YES];
    [self clearMap];
    isFriendAnnotationType = TRUE;
    isMutualFriendType = FALSE;
//    currDisplayedType = tNilLocType;
    [self makeAnnotationsForPerson:selectedPerson];
    [self showPins];
//    [self setBtnTitleForAllStates:locationTypeBtn withText:selectedPerson.name];
     [_slidingController showFriendMenu:selectedPerson];
}
- (void)didSelectMutualFriends:(Person*)person{
    [self.navigationController popToViewController:self animated:YES]; 
    isMutualFriendType = TRUE;
    isFriendAnnotationType = FALSE;
    mutualFriendsWith = person;
    [self showLocationType:tCurrentLocation];
}
-(void)backToFriends{
    if (isMutualFriendType) {
        [_slidingController showMutualFriendsMenu:mutualFriendsWith];
    }
    [self showLocationType:currDisplayedType];
}
- (void)backToAllFriends{
    isMutualFriendType = FALSE;
    [self showLocationType:currDisplayedType];
}

#pragma mark - LocTypeMenuController Delegate methods
-(void) didSelectLocType:(locTypeEnum)locType
{
    DebugLog(@"called delegate method");
    [self showLocationType:locType];
}

#pragma mark - CoodinateLookUpManager Delegate methods
-(void) someOperationAdded
{
    [self performSelectorOnMainThread:@selector(showLoadingView) withObject:nil waitUntilDone:NO];
}

-(void) showLoadingView
{
    if(!_startedOperations) {
        DebugLog(@"ShowLoadingView should only be called once.");
        _startedOperations = TRUE;
        //Show the loading banner when operations for locations is started.
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:2];
        [progressIndicator setAlpha:1.0];
        [UIView commitAnimations];
    }
}

-(void) allOperationFinished
{
    [self performSelectorOnMainThread:@selector(dissmissLoadingView) withObject:nil waitUntilDone:NO];
}
-(void) dissmissLoadingView
{
    //_finishedSaving flag make sure this is called only once per user session.
    if (!_finishedSaving) {
        _finishedSaving = TRUE;
        [self savePlacesToDisk];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:2];
        [progressIndicator setTransform:CGAffineTransformMakeTranslation(0, 110.0)];
        [UIView commitAnimations];   
    }
}

-(void) savePlacesToDisk
{
    [[[DataManagerSingleton sharedManager] placeContainer] savePlacesToDisk];
    DebugLog(@"Saving places data to file");
}

#pragma mark - Screen shot methods
-(IBAction)takeScreenShot:(UIButton*)sender
{
    //Hide most controls
    [settingsBtn setHidden:TRUE];
    [searchBtn setHidden:TRUE];
    [cameraBtn setHidden:TRUE];
    [progressIndicator setHidden:TRUE];

    UIImage* screenShot = [self doTakeScreenShot];
    
    //Animate the flash effect.
    UIView *whiteScreen = [[UIView alloc] initWithFrame:self.view.bounds];
    [whiteScreen setBackgroundColor: [UIColor whiteColor]];
    [whiteScreen setAlpha:1];
    [self.view addSubview:whiteScreen];
    [UIView animateWithDuration:1.0 animations:^
     {
         [whiteScreen setAlpha:0.0];
     }
                     completion:^(BOOL finished)
     {
         [whiteScreen removeFromSuperview];
         
         //Show those controls again
         [self showScreeShotMenu:screenShot];
         [settingsBtn setHidden:FALSE];
         [searchBtn setHidden:FALSE];
         [cameraBtn setHidden:FALSE];
         [progressIndicator setHidden:FALSE];
         
     }];
}


-(UIImage*) doTakeScreenShot
{
    //This code snippet is taken directly from apple documentation at http://developer.apple.com/library/ios/#qa/qa1703/_index.html

    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) 
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
   // CGContextRotateCTM (context, radians(-90));
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
