//
//  AbstractSlidingController.h
//  MappMe
//
//  Created by Parker Spielman on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"


@interface SlidingContainer : UIViewController{
// 
    //IBOutlet UIView* backgroundView;
//    IBOutlet UIView* toggleButton;
    int displayHeight;
}

@property (nonatomic, weak) IBOutlet UIView *buttonContainer;
@property (nonatomic, weak) IBOutlet UIButton *toggleButton;
@property (nonatomic) int displayHeight;

-(IBAction)toggle:(id)sender;
//So sub button menus can close controller on button press
-(void)closeMenu;
- (void)presentInParentViewController:(UIViewController *)parentViewController;
- (void)dismissFromParentViewController;

//Buttons to switch view contexts
-(void)selectedFriendMenu:(Person*)person;
-(void)showMainMenu;
-(void)showMutualFriendsMenu:(Person*)person;
@end
