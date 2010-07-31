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
#import "ErrorHandler.h"
#import "LJManager.h"

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	activityIndicatorItem.customView = activityIndicatorView;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managerDidCreateSession:) name:LJManagerDidCreateSessionNotification object:ljManager];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managerDidCreateSession:) name:LJManagerDidFailNotification object:ljManager];
}

- (void)viewDidUnload {
	self.navigationItem.rightBarButtonItem = nil;
	self.toolbarItems = nil;
	[super viewDidUnload];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[lastURL release];
	lastURL = nil;
	
	self.navigationItem.rightBarButtonItem = nil;
	self.navigationItem.title = nil;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.navigationController setToolbarHidden:YES animated:YES];
}

#ifndef LITEVERSION
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIDeviceOrientationPortrait || UIDeviceOrientationIsLandscape(interfaceOrientation);
}
#endif

#pragma mark -
#pragma mark UIWebView delegate

- (void)webViewDidFinishLoad:(UIWebView *)wv {
	[networkActivityIndicator hide];
	webView.alpha = 1.0f;
	self.navigationItem.rightBarButtonItem = nil;
	[self updateToolbarButtons:NO];
	self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
	[self webViewDidFinishLoad:wv];
	[errorHandler showErrorMessage:NSLocalizedString(@"Failed to load a web page", nil) title:NSLocalizedString(@"Web page error", nil)];
}

- (void)webViewDidStartLoad:(UIWebView *)wv {
	self.navigationItem.rightBarButtonItem = activityIndicatorItem;
	[self updateToolbarButtons:YES];

	[networkActivityIndicator show];
}

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	[ljManager setHTTPCookiesForAccount:lastAccount];
	self.navigationItem.title = [[request URL] absoluteString];
	return YES;
}

#pragma mark -

- (void)managerDidCreateSession:(NSNotification *)notitication {
	if (lastAccount == [[notitication userInfo] objectForKey:@"account"]) {
		[webView loadRequest:[NSURLRequest requestWithURL:lastURL]];
	}
}

- (void)openURL:(NSURL *)URL account:(LJAccount *)account {
	webView.alpha = 0.0f;
	
	[lastURL release];
	lastURL = [URL retain];
	
	lastAccount = account;
	
	self.navigationItem.title = NSLocalizedString(@"Loading...", nil);
	self.navigationItem.rightBarButtonItem = activityIndicatorItem;
	[ljManager createSessionForAccount:account];
}

- (void)updateToolbarButtons:(BOOL)loading {
	backButton.enabled = webView.canGoBack;
	forwardButton.enabled = webView.canGoForward;
	self.toolbarItems = [NSArray arrayWithObjects:backButton, flexSpace1, forwardButton, flexSpace2, flexSpace3, loading ? stopButton : reloadButton, nil];
}

@end
