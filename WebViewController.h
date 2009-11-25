//
//  WebViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.24.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController {
	
	UIWebView *webView;
	UIActivityIndicatorView *activityIndicatorView;
	
	NSArray *toolbarItems;

}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;

- (void) openURL:(NSURL *)url;
- (void) updateToolbarButtons:(BOOL)loading;

@end
