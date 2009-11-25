//
//  WebViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.24.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LJAccount;

@interface WebViewController : UIViewController {
	
	UIWebView *webView;
	UIActivityIndicatorView *activityIndicatorView;
	
	NSArray *toolbarItems;

	// saraksts ar serveriem un kontiem, kuriem autorizācija ir izpildīta
	NSMutableDictionary *loggedinServers;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;

- (void)openURL:(NSURL *)url account:(LJAccount *)account;
- (void)updateToolbarButtons:(BOOL)loading;
- (BOOL)createSessionForAccount:(LJAccount *)account silent:(BOOL)silent;

@end
