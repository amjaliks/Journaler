//
//  WebFriendsPageController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.24.
//  Copyright 2009 A25. All rights reserved.
//

#import "WebFriendsPageController.h"

#import "Macros.h"

#import "LiveJournal.h"
#import "AccountEditorController.h"
#import "JournalerAppDelegate.h"
#import "WebViewController.h"
#import "NetworkActivityIndicator.h"

@implementation WebFriendsPageController

- (id) initWithAccount:(LJAccount *)newAccount {
	if (self = [super initWithAccount:newAccount]) {
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	webView.scalesPageToFit = YES;
	webView.delegate = self;
	webView.alpha = 0.0f;
	
	friendsPageView = webView;
	
	[self.view addSubview:webView];
	self.view.autoresizingMask =
	webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (!loggedin && refreshTurnedOffMessage && DEFAULT_BOOL(@"refresh_on_start")) {
		[self showActivityIndicator];
		[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
	}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	if (!loggedin) {
		if (DEFAULT_BOOL(@"refresh_on_start")) {
			[self performSelectorInBackground:@selector(login) withObject:nil];
		} else if (!refreshTurnedOffMessage) {
			NSString *path = [[NSBundle mainBundle] pathForResource:@"RefreshTurnedOff" ofType:@"html"];
			NSURL *URL = [NSURL fileURLWithPath:path];
			NSURLRequest *request = [NSURLRequest requestWithURL:URL];
			[self showActivityIndicator];
			[webView loadRequest:request];
			refreshTurnedOffMessage = YES;
		}
	}
}

- (void) dealloc {
	[friendsPageURL release];
	[friendsPageAltURL release];

	[super dealloc];
}


#pragma mark Autorizācija

- (void)login {
	@synchronized (self) {
		if (!loggedin) {
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			
			loggedin = YES;
			[self performSelectorInBackground:@selector(showActivityIndicator) withObject:nil];
			
			if ([APP_WEB_VIEW_CONTROLLER createSessionForAccount:account silent:NO]) {
				[self loadFriendsPage];
			} else {
				[self hideActivityIndicator];
			}
			
			[pool release];
		}
	}
}

- (void)loadFriendsPage {
	NSString *URLString = [[NSString stringWithFormat:@"http://%@/~%@/friends/%@", 
						account.server, account.user, 
							friendsPageFilter.filterType == FilterTypeGroup ? friendsPageFilter.group : @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *URL = [NSURL URLWithString:URLString];
	NSURLRequest *req = [NSURLRequest requestWithURL:URL];
	[webView loadRequest:req];
}

#pragma mark Pogas
- (void)refresh {
	if (loggedin) {
		[self performSelectorInBackground:@selector(showActivityIndicator) withObject:nil];
		[self loadFriendsPage];
	} else {
		[self login];
	}
}

- (void)filterFriendsPage {
	[self refresh];
}

#pragma mark WebViewDelegate metode

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
	[[NetworkActivityIndicator sharedInstance] hide];
	[self hideActivityIndicator];
	
	webView.alpha = 1.0f;
}

- (BOOL)webView:(UIWebView *)webView_ shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *URL = [request URL];
	if (navigationType == UIWebViewNavigationTypeReload || navigationType == UIWebViewNavigationTypeOther) {
		[[NetworkActivityIndicator sharedInstance] show];
		
		return YES;
	} else {
		WebViewController *webViewController = APP_WEB_VIEW_CONTROLLER;
		[self.navigationController pushViewController:webViewController animated:YES];
		[webViewController openURL:URL account:account];
		
		return NO;
	}
}

@end
