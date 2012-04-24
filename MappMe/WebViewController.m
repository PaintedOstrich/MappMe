//
//  WebViewController.m
//  MappMe
//
//  Created by #BAL on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

@synthesize url;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [webview setDelegate:self];
    [webview loadRequest:[NSURLRequest requestWithURL:url]];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark UIWebViewDelegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	activityIndicator.hidden=FALSE;
	[activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	activityIndicator.hidden=TRUE;
	[activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[activityIndicator stopAnimating];
    
	NSLog(@"Error Loading web page");
}

@end
