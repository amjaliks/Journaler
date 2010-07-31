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
	IBOutlet UIWebView *webView;
	IBOutlet UIBarButtonItem *activityIndicatorItem;
	IBOutlet UIActivityIndicatorView *activityIndicatorView;
	
	IBOutlet UIBarItem *backButton;
	IBOutlet UIBarItem *flexSpace1;
	IBOutlet UIBarItem *forwardButton;
	IBOutlet UIBarItem *flexSpace2;
	IBOutlet UIBarItem *flexSpace3;
	IBOutlet UIBarItem *reloadButton;
	IBOutlet UIBarItem *stopButton;
	
	NSURL *lastURL;
	LJAccount *lastAccount;
}

- (void)managerDidCreateSession:(NSNotification *)notitication;
- (void)openURL:(NSURL *)URL account:(LJAccount *)account;
- (void)updateToolbarButtons:(BOOL)loading;

@end
