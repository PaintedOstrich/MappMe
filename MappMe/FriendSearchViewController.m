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
    //An nested array of Friend objectis to faciliate indexing
    NSMutableArray* friends;
    NSMutableArray* searchResults;
    BOOL searching;
    BOOL letUserSelectRow;
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
    
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    
    friends = [NSMutableArray arrayWithCapacity:1];
    searchResults = [NSMutableArray arrayWithCapacity:1];
    friendList = [[[delegate peopleContainer] people] allValues];
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

    if(searching)
        cell.textLabel.text = [[searchResults objectAtIndex:indexPath.row] name];
    else {
        Friend *person = [[friends objectAtIndex:indexPath.section]
                          objectAtIndex:indexPath.row];
        cell.textLabel.text = [[delegate personNameAndIdMapping] getNameFromId:person.userId];
    }
    
    
//    cell.detailTextLabel.text = [item objectForKey:@"secondaryTitleKey"];
//    NSString *path = [[NSBundle mainBundle] pathForResource:[item objectForKey:@"imageKey"] ofType:@"png"];
//    UIImage *theImage = [UIImage imageWithContentsOfFile:path];
    //cell.imageView.image = [[delegate fbImageHandler] getProfPicFromId:uid];
    return cell;

}

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(letUserSelectRow)
        return indexPath;
    else
        return nil;
}


#pragma mark - Table view delegate
  
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    DebugLog(@"selected ");
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    NSString *uid = [[delegate personNameAndIdMapping] getIdFromName:cell.textLabel.text];
//    [searchDelegate didSelectFriend:uid];
//    
//    //Get the selected country
//    
//    NSString *selectedCountry = nil;
//    
//    if(searching)
//        selectedCountry = [copyListOfItems objectAtIndex:indexPath.row];
//    else {
//        
//        NSDictionary *dictionary = [listOfItems objectAtIndex:indexPath.section];
//        NSArray *array = [dictionary objectForKey:@"Countries"];
//        selectedCountry = [array objectAtIndex:indexPath.row];
//    }
//    
//    //Initialize the detail view controller and display it.
//    DetailViewController *dvController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]];
//    dvController.selectedCountry = selectedCountry;
//    [self.navigationController pushViewController:dvController animated:YES];
//    [dvController release];
//    dvController = nil;

}

#pragma mark - Search bar methods
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    
    searching = YES;
    letUserSelectRow = NO;
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    
    //Remove all objects first.
    [searchResults removeAllObjects];
    
    if([searchText length] > 0) {
        searching = YES;
        [self searchTableView];
    }
    else {
        searching = NO;
    }
    
    [self.tableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    
    [self searchTableView];
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

- (void) doneSearching_Clicked:(id)sender {
    
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    
    letUserSelectRow = YES;
    searching = NO;
    [self.tableView reloadData];
}

@end
