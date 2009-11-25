//
//  WebViewController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.24.
//  Copyright 2009 A25. All rights reserved.
//

#import "WebViewController.h"


@implementation WebViewController

@synthesize webView;
@synthesize activityIndicatorView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	toolbarItems = [[((UIToolbar *)[self.view viewWithTag:10]).items copy] retain];
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
	self.navigationItem.rightBarButtonItem = item;
	//[activityIndicatorView startAnimating];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (void) openURL:(NSURL *)url {
	[webView removeFromSuperview];
	[webView loadRequest:[NSURLRequest requestWithURL:url]];
	self.navigationItem.title = [url absoluteString];
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView {
	[self.view addSubview:webView];
	[activityIndicatorView stopAnimating];
	[self updateToolbarButtons:NO];
	self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[activityIndicatorView startAnimating];
	[self updateToolbarButtons:YES];
}

- (void) updateToolbarButtons:(BOOL)loading {
	UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:10];
	
	NSMutableArray *items = [NSMutableArray arrayWithCapacity:7];
	NSUInteger i = 0;
	for (UIBarButtonItem *item in toolbarItems) {
		i++;
		if (i == 1) {
			item.enabled = webView.canGoBack;
		} else if (i == 3) {
			item.enabled = webView.canGoForward;
		}
		if (((i != 5 && loading) || (i != 6 && !loading)) && i <= 6) {
			[items addObject:item];
		}
	}
	[toolbar setItems:items animated:NO];
}

@end
