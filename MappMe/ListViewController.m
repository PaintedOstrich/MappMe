//
//  ListViewController.m
//  MappMe
//
//  Created by #BAL on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListViewController.h"
#import "MappMeAppDelegate.h"
#import "Friend.h"
#import "WebViewController.h"


@implementation ListViewController{
    MappMeAppDelegate *delegate;
    NSArray * friendIds;
    NSString *selectedFriend_id;
}

@synthesize tableView,selectedCity;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Helper Methods to masage and gether data.
/*
 * We may need to format city name somehow in the future.
 */
-(NSString*) formatCityStr:(NSString*) cityName {
    return cityName;
}

-(NSArray*) getFriendsInCity:(NSString*) cityName{
    NSString * city_id = [delegate.placeIdMapping getIdFromPlace:selectedCity];
    
    NSDictionary * currentGrouping = [delegate.peopleContainer getCurrentGrouping];
    return [[currentGrouping objectForKey:city_id] allObjects];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    delegate = (MappMeAppDelegate *)[[UIApplication sharedApplication] delegate];
    selectedCity = [self formatCityStr:selectedCity];
    NSLog(@"%@",selectedCity);
    self.navigationItem.title = selectedCity;
    
    friendIds = [self getFriendsInCity:selectedCity];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [friendIds count];
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *friend_id = [friendIds objectAtIndex:indexPath.row];
    cell.textLabel.text = [[delegate peopleContainer] getNameFromId:friend_id];
    
    //Parker, the following line is causing the slowness in rendering a table list with
    //more than 20 items. Please thread your image fetching code, use a placeholder first,
    //and swap in the right image along the way(just like what we did previously).
    //It is not good to download profile pics when it is not needed as it takes up the user's 3G data.
    //cell.imageView.image = [[delegate fbImageHandler] getProfPicFromId:friend_id];
    cell.imageView.image = [UIImage imageNamed:@"profile.png"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedFriend_id = [friendIds objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"showwebview" sender:nil];
}

#pragma mark - Transition Functions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"showwebview"]){
		NSString *urlStr = [[NSString alloc] initWithFormat:@"%@%@",@"http://m.facebook.com/profile.php?id=",selectedFriend_id];
		NSURL *url =[[NSURL alloc] initWithString:urlStr];
        WebViewController *controller = segue.destinationViewController;
        controller.url = url;
    }
}

@end
