//
//  AccountViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.04.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostEditorController.h"
#import "PostViewController.h"
#import "Model.h"

@class LJAccount, UserPicCache;

@protocol AccountViewControllerDataSource;


@interface AccountViewController : UIViewController <UIWebViewDelegate, PostEditorControllerDataSource, PostEditorControllerDelegate, PostViewControllerDataSource, UITableViewDataSource, UITableViewDelegate> {
	UIViewController *tabBar;
	
	UIView *masterView;
	UITableView *ljAccountView;
	UIView *otherAccountView;
	
	UIWebView *webView;
	
	UIToolbar *toolbar;
	UIBarButtonItem *backButton;
	UIBarButtonItem *fixedSpace;
	UIBarButtonItem *forwardButton;
	UIBarButtonItem *flexibleSpace;
	UIBarButtonItem *refreshButton;
	UIBarButtonItem *stopButton;
	
	UIBarButtonItem *newPostOther;
	
	NSMutableArray *posts;
	UITableViewCell *templateCell;
	
	id<AccountViewControllerDataSource> dataSource;
	
	Post *selectedPost;
	
	UIViewController *postEditorController;
	UIViewController *postViewController;
		
	LJAccount *previousAccount;
}

@property (nonatomic, retain) IBOutlet UIViewController *tabBar;
@property (nonatomic, retain) IBOutlet UIView *masterView;

@property (nonatomic, retain) IBOutlet UITableView *ljAccountView;
@property (nonatomic, retain) IBOutlet UIView *otherAccountView;

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *fixedSpace;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *flexibleSpace;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *stopButton;

@property (nonatomic, retain) IBOutlet UITableViewCell *templateCell;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *newPostOther;

@property (nonatomic, retain) IBOutlet id<AccountViewControllerDataSource> dataSource;

@property (nonatomic, retain) IBOutlet UIViewController *postEditorController;
@property (nonatomic, retain) IBOutlet UIViewController *postViewController;

- (IBAction) goToUpdate;

@end


@protocol AccountViewControllerDataSource<NSObject>

@optional
	- (LJAccount *)selectedAccountForAccountViewController:(AccountViewController *)accountViewController;

@end
