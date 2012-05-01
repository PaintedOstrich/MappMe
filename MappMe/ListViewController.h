//
//  ListViewController.h
//  MappMe
//
//  Created by #BAL on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@class MyAnnotation;

@interface ListViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    MyAnnotation *selectedAnnotation;
    MainViewController *mvc;
}

@property(nonatomic,strong)	MyAnnotation *selectedAnnotation;
@property(nonatomic,strong) MainViewController *mvc; 
@end
