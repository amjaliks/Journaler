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
#import "ErrorHandler.h"

@implementation WebFriendsPageController

@synthesize account;
@synthesize mainView = webView;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	account = accountProvider.account;
	
	webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	webView.scalesPageToFit = YES;
	webView.delegate = self;
	webView.alpha = 0.0f;
	
	friendsPageView = webView;
	
	[self.view addSubview:webView];
	self.view.autoresizingMask =
	webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managerDidCreateSession:) name:LJManagerDidCreateSessionNotification object:ljManager];
}

- (void)viewDidUnload {
	webView.delegate = nil;
	[webView release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (!initialized) {
		initialized = YES;

		if (DEFAULT_BOOL(@"refresh_on_start")) {
			[self login];
		} else {
			[self loadRefreshRequiredPage];
		}
	}
}

#pragma mark Autorizācija

- (void)login {
	[self showActivityIndicator];	
	[ljManager createSessionForAccount:self.account];
}

- (void)loadFriendsPage {
	NSString *URLString = [[NSString stringWithFormat:@"http://%@/~%@/friends/%@", 
						self.account.server, self.account.user, 
							friendsPageFilter.filterType == FilterTypeGroup ? friendsPageFilter.group.name : @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URLString]]];
}

- (void)loadBlankPage {
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}

- (void)loadRefreshRequiredPage {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"RefreshTurnedOff" ofType:@"html"];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
}

- (void)managerDidCreateSession:(NSNotification *)notification {
	if (self.account == [[notification userInfo] objectForKey:@"account"]) {
		[self loadFriendsPage];
		[self hideActivityIndicator];
	}
}

- (void)managerDidFail:(NSNotification *)notification {
	if (self.account == [[notification userInfo] objectForKey:@"account"]) {
		[self loadBlankPage];
		[self hideActivityIndicator];
		[errorHandler showErrorMessageForAccount:self.account 
											text:[errorHandler decodeError:[[[notification userInfo] objectForKey:@"error"] code]]
										   title:NSLocalizedString(@"Login error", nil)];
	}
} 

#pragma mark Pogas
- (void)refresh {
	[self login];
}

- (void)filterFriendsPage {
	[self refresh];
}

#pragma mark WebViewDelegate metode

- (void)webViewDidFinishLoad:(UIWebView *)wv {
	[networkActivityIndicator hide];
	[self hideActivityIndicator];
	webView.alpha = 1.0f;
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
	[self webViewDidFinishLoad:wv];
	
	[errorHandler showErrorMessageForAccount:self.account 
										text:NSLocalizedString(@"Failed to load friends page", nil)
									   title:NSLocalizedString(@"Friends pages", nil)];
}

- (void)webViewDidStartLoad:(UIWebView *)wv {
	[networkActivityIndicator show];
}

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *URL = [request URL];
	if (navigationType == UIWebViewNavigationTypeReload || navigationType == UIWebViewNavigationTypeOther) {
		[ljManager setHTTPCookiesForAccount:self.account];
		return YES;
	} else {
		[self.navigationController pushViewController:appWebViewController animated:YES];
		[appWebViewController openURL:URL account:self.account];
		return NO;
	}
}

@end
