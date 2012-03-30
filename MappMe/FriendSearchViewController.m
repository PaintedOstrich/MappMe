//
//  FriendSearchViewController.m
//  MappMe
//
//  Created by Parker Spielman on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendSearchViewController.h"
#import "MappMeAppDelegate.h"
#import "DebugLog.h"

@implementation FriendSearchViewController{
    MappMeAppDelegate* delegate;
    //All available friends in a flat array
    NSArray* friendList;
    //A nested array of Friend objectis to faciliate indexing in table
    NSMutableArray* friends;
    NSMutableArray* searchResults;
    
    //YES when we are doing searching
    BOOL searching;
    
    //the view of this controller will cover the table when searching
    //tapping the view has the same effect as tapping the cancel button.
    OverlayViewController* overlayViewCtrl;
}

@synthesize searchDelegate;

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
    delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    searchBar.delegate = self;
    
    //Boilplate code to index friendlist so table can show an indexed, sorted list.
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    
    friends = [NSMutableArray arrayWithCapacity:1];
    searchResults = [NSMutableArray arrayWithCapacity:1];
    friendList = [[[delegate.mainDataManager peopleContainer] people] allValues];
    for (Friend* person in friendList) {
        NSUInteger sect = (NSUInteger) [theCollation sectionForObject:person collationStringSelector:@selector(name)];
        person.sectionNumber = sect;
    }
    
    NSInteger highSection = [[theCollation sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
    for (int i=0; i<=highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sectionArrays addObject:sectionArray];
    }
    
    for (Friend *person in friendList) {
        [(NSMutableArray *)[sectionArrays objectAtIndex:person.sectionNumber]
         addObject:person];
    }
    
    
    for (NSMutableArray *sectionArray in sectionArrays) {
        NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray
                                            collationStringSelector:@selector(name)];
        [friends addObject:sortedSection];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    searchBar = nil;
    overlayViewCtrl = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view data source
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSArray* toR = [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
    return toR;
}


- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    if(searching) {
        return @"";
    }

    if ([[friends objectAtIndex:section] count] > 0) {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles]
                objectAtIndex:section];
    }
    return nil;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString
                                                                             *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation]
            sectionForSectionIndexTitleAtIndex:index];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (searching)
        return 1;
    else
    return [friends count];
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if (searching)
        return [searchResults count];
    else {
        return [[friends objectAtIndex:section] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"personCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }

    Friend *person;
    if(searching)
        person = [searchResults objectAtIndex:indexPath.row];
    else {
        person = [[friends objectAtIndex:indexPath.section]
                          objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = person.name;

    return cell;

}

#pragma mark - Table view delegate
  
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Friend *person;
    if(searching)
        person = [searchResults objectAtIndex:indexPath.row];
    else {
        person = [[friends objectAtIndex:indexPath.section]
                  objectAtIndex:indexPath.row];
    }
    [searchDelegate didSelectFriend:person.userId];
}
#pragma mark - Methods to manage show and hide of the overlay

-(void) removeOverlay {
    if (overlayViewCtrl == nil)
        return;
    [overlayViewCtrl.view removeFromSuperview];
}

-(void) addOverlay {
    //Add the overlay view if not existent
    if(overlayViewCtrl == nil) {
        overlayViewCtrl = [[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:[NSBundle mainBundle]];
        CGFloat yaxis = self.navigationController.navigationBar.frame.size.height;
        CGFloat width = self.view.frame.size.width;
        CGFloat height = self.view.frame.size.height;
        //Parameters x = origion on x-axis, y = origon on y-axis.
        CGRect frame = CGRectMake(0, yaxis, width, height);
        overlayViewCtrl.view.frame = frame;
        overlayViewCtrl.view.backgroundColor = [UIColor grayColor];
        overlayViewCtrl.view.alpha = 0.5;
        overlayViewCtrl.delegate = self;
    }
    
    [self.tableView insertSubview:overlayViewCtrl.view aboveSubview:self.parentViewController.view];
}

#pragma mark - Search bar methods

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    [self addOverlay];
    searching = YES;
}

- (void) searchTableView {
    
    NSString *searchText = searchBar.text;
    NSMutableArray *searchArray = [[NSMutableArray alloc] init];
    
    [searchArray addObjectsFromArray:friendList];
    
    for (Friend* person in searchArray)
    {
        NSString *sTemp = person.name;
        NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if (titleResultsRange.length > 0)
            [searchResults addObject:person];
    }
    
    searchArray = nil;
}
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    
    //Remove all objects first.
    [searchResults removeAllObjects];
    
    if([searchText length] > 0) {
        searching = YES;
        [self removeOverlay];
        [self searchTableView];
    }
    else {
        searching = NO;
        [self addOverlay];
    }
    
    [self.tableView reloadData];
}



- (void)searchBarCancelButtonClicked:(UISearchBar *)sBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [self removeOverlay];
}

- (void) doneSearching_Clicked:(id)sender {
    
    searchBar.text = @"";
    [searchBar resignFirstResponder];

    searching = NO;
    
    [self removeOverlay];
    [self.tableView reloadData];
}

#pragma mark - OverlayViewController delegate methods
-(void) overlayTouched:(OverlayViewController *)overlayController {
    [self doneSearching_Clicked:nil];
}



@end
