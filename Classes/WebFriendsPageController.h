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
	LJAccount *account;
	UIWebView *webView;
	
	// pazīme, vai ir veikta autorizācija
	BOOL initialized;
}

- (void)login;
- (void)loadFriendsPage;
- (void)loadBlankPage;
- (void)loadRefreshRequiredPage;

- (void)managerDidCreateSession:(NSNotification *)notification;

@end
