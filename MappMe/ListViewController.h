//
//  ListViewController.h
//  MappMe
//
//  Created by #BAL on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyAnnotation;

@interface ListViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    MyAnnotation *selectedAnnotation;
}

@property(nonatomic,strong)	MyAnnotation *selectedAnnotation;
@end
