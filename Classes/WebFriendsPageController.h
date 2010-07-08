//
//  WebFriendsPageController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.24.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FriendsPageController.h"

@interface WebFriendsPageController : FriendsPageController <UIWebViewDelegate> {
	//
	UIWebView *webView;
	
	// draugu lapas adrese
	NSURL *friendsPageURL;
	NSURL *friendsPageAltURL;
	// pazīme, vai ir veikta autorizācija
	BOOL loggedin;
	// pazīme, ka tiek attēlots paziņojums par atslēgtu automātisku ielādi
	BOOL refreshTurnedOffMessage;
}

- (void)login;
- (void)loadFriendsPage;

@end
