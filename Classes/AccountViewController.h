//
//  AccountViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.04.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>


@class LJAccount;

@protocol AccountViewControllerDataSource;


@interface AccountViewController : UIViewController <UIWebViewDelegate> {
	UIWebView *webView;
	
	UIToolbar *toolbar;
	UIBarButtonItem *backButton;
	UIBarButtonItem *fixedSpace;
	UIBarButtonItem *forwardButton;
	UIBarButtonItem *flexibleSpace;
	UIBarButtonItem *refreshButton;
	UIBarButtonItem *stopButton;
	
	//UINavigationItem *title;
	
	id<AccountViewControllerDataSource> dataSource;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *fixedSpace;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *flexibleSpace;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *stopButton;

//@property (nonatomic, retain) IBOutlet UINavigationItem *title;
@property (nonatomic, retain) IBOutlet id<AccountViewControllerDataSource> dataSource;

- (IBAction) goToUpdate;

@end


@protocol AccountViewControllerDataSource<NSObject>

@optional
	- (LJAccount *)selectedAccountForAccountViewController:(AccountViewController *)accountViewController;

@end;