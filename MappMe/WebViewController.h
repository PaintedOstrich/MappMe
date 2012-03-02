//
//  WebViewController.h
//  MappMe
//
//  Created by #BAL on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>{
    IBOutlet UIWebView *webview;
    IBOutlet UIActivityIndicatorView* activityIndicator;
}

@end
