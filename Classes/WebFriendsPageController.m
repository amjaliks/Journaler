//
//  WebFriendsPageController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.24.
//  Copyright 2009 A25. All rights reserved.
//

#import "WebFriendsPageController.h"

#import "LiveJournal.h"
#import "AccountEditorController.h"
#import "JournalerAppDelegate.h"
#import "WebViewController.h"

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


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	if (!loggedin) {
		refreshButtonItem.enabled = NO;
		[self performSelectorInBackground:@selector(login) withObject:nil];
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
			loggedin = YES;
			[self performSelectorInBackground:@selector(showStatusLine) withObject:nil];

			LJGetChallenge *challenge = [LJGetChallenge requestWithServer:account.server];
			if ([challenge doRequest]) {
				
				LJSessionGenerate *session = [LJSessionGenerate requestWithServer:account.server user:account.user password:account.password challenge:challenge.challenge];
				if ([session doRequest]) {
					NSDictionary *cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"ljsession", NSHTTPCookieName, session.ljsession, NSHTTPCookieValue, [NSString stringWithFormat:@".%@", account.server], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
					NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
					[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
					
					cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"ljmastersession", NSHTTPCookieName, session.ljsession, NSHTTPCookieValue, [NSString stringWithFormat:@".%@", account.server], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
					cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
					[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
					
					NSArray *parts = [session.ljsession componentsSeparatedByString:@":"];
					cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"ljloggedin", NSHTTPCookieName, [NSString stringWithFormat:@"%@:%@", [parts objectAtIndex:1], [parts objectAtIndex:2]], NSHTTPCookieValue, [NSString stringWithFormat:@".%@", account.server], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
					cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
					[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
					
					NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:friendsPageURL];
					[webView loadRequest:req];
				} else {
					showErrorMessage(@"Friend page error", session.error);
				}
			} else {
				showErrorMessage(@"Friend page error", challenge.error);
			}
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
	[self hideStatusLine];
	refreshButtonItem.enabled = YES;
}

- (BOOL)webView:(UIWebView *)webView_ shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *URL = [request URL];
	if (navigationType == UIWebViewNavigationTypeReload || navigationType == UIWebViewNavigationTypeOther) {
		return YES;
	} else {
		WebViewController *webViewController = APP_WEB_VIEW_CONTROLLER;
		[self.navigationController pushViewController:webViewController animated:YES];
		[webViewController openURL:URL];
		
		return NO;
	}
}
@end
