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
		NSString *URLFormat;
		NSString *altURLFormat;
		if ([@"dreamwidth.org" isEqualToString:account.server]) {
			URLFormat = @"http://%@.%@/read";
			altURLFormat = @"http://%@/~%@/read";
			friendsPageURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:URLFormat, newAccount.user, newAccount.server]];
			friendsPageAltURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:altURLFormat, newAccount.server, newAccount.user]];
		} else {
			URLFormat = @"http://%@/~%@/friends";
			altURLFormat = @"http://%@.%@/friends";
			friendsPageURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:URLFormat, newAccount.server, newAccount.user]];
			friendsPageAltURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:altURLFormat, newAccount.user, newAccount.server]];
		}
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	webView.scalesPageToFit = YES;
	webView.delegate = self;
	
	friendsPageView = webView;
	
	[self.view addSubview: webView];
	
#ifdef LITEVERSION
	[self initAdMobView];
#endif
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (!loggedin && refreshTurnedOffMessage && DEFAULT_BOOL(@"refresh_on_start")) {
		[self showStatusLine];
		[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
	}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	if (!loggedin) {
		if (DEFAULT_BOOL(@"refresh_on_start")) {
			refreshButtonItem.enabled = NO;
			[self performSelectorInBackground:@selector(login) withObject:nil];
		} else if (!refreshTurnedOffMessage) {
			NSString *path = [[NSBundle mainBundle] pathForResource:@"RefreshTurnedOff" ofType:@"html"];
			NSURL *URL = [NSURL fileURLWithPath:path];
			NSURLRequest *request = [NSURLRequest requestWithURL:URL];
			[self showStatusLine];
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
			[self performSelectorInBackground:@selector(showStatusLine) withObject:nil];
			
			if ([APP_WEB_VIEW_CONTROLLER createSessionForAccount:account silent:NO]) {
				NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:friendsPageURL];
				[webView loadRequest:req];
			} else {
				[self hideStatusLine];
			}
			
			[pool release];
		}
	}
}

#pragma mark Pogas
- (void)refresh {
	refreshButtonItem.enabled = NO;
	if (loggedin) {
		[self performSelectorInBackground:@selector(showStatusLine) withObject:nil];
		[webView reload];
	} else {
		[self login];
	}
}

#pragma mark WebViewDelegate metode

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
	[[NetworkActivityIndicator sharedInstance] hide];

	[self hideStatusLine];
	refreshButtonItem.enabled = YES;
	
#ifdef LITEVERSION
	[self refreshAdMobView];
#endif
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

#ifdef LITEVERSION
- (NSString *)keywords {
	NSString *subject = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	if (subject) {
		return subject;
	};

	// ja neko neizdevās atrast, izmantojam iebūvētos atslēgas vārdus
	return [super keywords]; 
}
#endif

@end
