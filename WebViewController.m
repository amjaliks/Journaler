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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)dealloc {
	[loggedinServers release];

    [super dealloc];
}

- (void) openURL:(NSURL *)url account:(LJAccount *)account {
	[self updateToolbarButtons:NO];

	[webView removeFromSuperview];
	[webView stopLoading];
	
	[self createSessionForAccount:account silent:YES];
	[webView loadRequest:[NSURLRequest requestWithURL:url]];
	
	self.navigationItem.title = [url absoluteString];
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView {
	[[NetworkActivityIndicator sharedInstance] hide];

	[self.view addSubview:webView];
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
		if (((i != 6 && loading) || (i != 7 && !loading)) && i <= 7) {
			[items addObject:item];
		}
	}
	[toolbar setItems:items animated:NO];
}

- (BOOL)createSessionForAccount:(LJAccount *)account silent:(BOOL)silent{
	@synchronized (loggedinServers) {
		NSString *user = [loggedinServers objectForKey:account.server];
		if (!user || ![user isEqualToString:account.user]) {
			LJGetChallenge *challenge = [LJGetChallenge requestWithServer:account.server];
			if ([challenge doRequest]) {
				
				LJSessionGenerate *session = [LJSessionGenerate requestWithServer:account.server user:account.user password:account.password challenge:challenge.challenge];
				if ([session doRequest]) {
					NSDictionary *cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"ljsession", NSHTTPCookieName, session.ljsession, NSHTTPCookieValue, [NSString stringWithFormat:@".%@", account.server], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
					NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
					[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
					[cookie release];
					
					cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"ljmastersession", NSHTTPCookieName, session.ljsession, NSHTTPCookieValue, [NSString stringWithFormat:@".%@", account.server], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
					cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
					[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
					[cookie release];
					
					NSArray *parts = [session.ljsession componentsSeparatedByString:@":"];
					cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"ljloggedin", NSHTTPCookieName, [NSString stringWithFormat:@"%@:%@", [parts objectAtIndex:1], [parts objectAtIndex:2]], NSHTTPCookieValue, [NSString stringWithFormat:@".%@", account.server], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
					cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
					[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
					[cookie release];
					
					[loggedinServers setObject:account.user forKey:account.server];
					return YES;
				} else {
					if (!silent) {
						showErrorMessage(@"Login error", decodeError(session.error));
					}
				}
			} else {
				if (!silent) {
					showErrorMessage(@"Login error", decodeError(challenge.error));
				}
			}
		}
	}
	return NO;
}

@end
