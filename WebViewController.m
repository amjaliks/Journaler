//
//  WebViewController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.24.
//  Copyright 2009 A25. All rights reserved.
//

#import "WebViewController.h"

#import "LiveJournal.h"
#import "NetworkActivityIndicator.h"
#import "ErrorHandling.h"

@implementation WebViewController

@synthesize webView;
@synthesize activityIndicatorView;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		loggedinServers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
	self.navigationItem.rightBarButtonItem = item;
	[item release];
}

- (void)viewDidUnload {
	self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#ifndef LITEVERSION
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIDeviceOrientationPortrait || UIDeviceOrientationIsLandscape(interfaceOrientation);
}
#endif

- (void)dealloc {
	[loggedinServers release];

    [super dealloc];
}

- (void) openURL:(NSURL *)url account:(LJAccount *)account {
	[self updateToolbarButtons:NO];

	[webView setAlpha:0.0f];
	
	[self createSessionForAccount:account silent:YES];
	[webView loadRequest:[NSURLRequest requestWithURL:url]];
	
	self.navigationItem.title = [url absoluteString];
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView {
	[[NetworkActivityIndicator sharedInstance] hide];

	//[self.view addSubview:webView];
	[webView setAlpha:1.0f];
	[activityIndicatorView stopAnimating];
	[self updateToolbarButtons:NO];
	self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[activityIndicatorView startAnimating];
	[self updateToolbarButtons:YES];
	
	[[NetworkActivityIndicator sharedInstance] show];
}

- (void) updateToolbarButtons:(BOOL)loading {
	backButton.enabled = webView.canGoBack;
	forwardButton.enabled = webView.canGoForward;
	NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:backButton, flexSpace1, forwardButton, flexSpace2, flexSpace3, loading ? stopButton : reloadButton, nil];
	self.toolbarItems = items;
	[items release];
}

- (BOOL)createSessionForAccount:(LJAccount *)account silent:(BOOL)silent{
	@synchronized (loggedinServers) {
		NSString *user = [loggedinServers objectForKey:account.server];
		if (!user || ![user isEqualToString:account.user]) {
			NSError *error;
			NSString *session;
			
			if (session = [[LJAPIClient client] generateSessionForAccount:account error:&error]) {
				NSDictionary *cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"ljsession", NSHTTPCookieName, session, NSHTTPCookieValue, [NSString stringWithFormat:@".%@", account.server], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
				NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
				[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
				[cookie release];
				
				cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"ljmastersession", NSHTTPCookieName, session, NSHTTPCookieValue, [NSString stringWithFormat:@".%@", account.server], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
				cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
				[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
				[cookie release];
				
				NSArray *parts = [session componentsSeparatedByString:@":"];
				cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"ljloggedin", NSHTTPCookieName, [NSString stringWithFormat:@"%@:%@", [parts objectAtIndex:1], [parts objectAtIndex:2]], NSHTTPCookieValue, [NSString stringWithFormat:@".%@", account.server], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
				cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
				[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
				[cookie release];
				
				[loggedinServers setObject:account.user forKey:account.server];
				return YES;
			} else {
				if (!silent) {
					showErrorMessage(@"Login error", decodeError([error code]));
				}
			}
		} else {
			return YES;
		}
	}
	return NO;
}

@end
