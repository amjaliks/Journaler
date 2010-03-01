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
	
	IBOutlet UIBarItem *backButton;
	IBOutlet UIBarItem *flexSpace1;
	IBOutlet UIBarItem *forwardButton;
	IBOutlet UIBarItem *flexSpace2;
	IBOutlet UIBarItem *flexSpace3;
	IBOutlet UIBarItem *reloadButton;
	IBOutlet UIBarItem *stopButton;

	// saraksts ar serveriem un kontiem, kuriem autorizācija ir izpildīta
	NSMutableDictionary *loggedinServers;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;

- (void)openURL:(NSURL *)url account:(LJAccount *)account;
- (void)updateToolbarButtons:(BOOL)loading;
- (BOOL)createSessionForAccount:(LJAccount *)account silent:(BOOL)silent;

@end
