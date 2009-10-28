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
#import "AccountEditorController.h"

@class LJAccount, UserPicCache, PostSummaryCell;

@protocol AccountViewControllerDataSource;


@interface AccountViewController : UIViewController <UIWebViewDelegate, PostEditorControllerDataSource, PostEditorControllerDelegate,
PostViewControllerDataSource, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, UIScrollViewDelegate, AccountEditorControllerDataSource, AccountEditorControllerDelegate> {
	UITabBarController *tabBar;
	
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
	UIBarButtonItem *postButton;
	UIBarButtonItem *refreshPostsButton;
	
	NSMutableArray *posts;
	PostSummaryCell *templateCell;
	
	id<AccountViewControllerDataSource> dataSource;
	
	Post *selectedPost;
	
	UIViewController *previousController;
	UIViewController *postEditorController;
	UIViewController *postViewController;
	UIViewController *friendsTabController;
	UIViewController *postEditorTabController;
		
	LJAccount *previousAccount;
				
	UIViewController *accountEditor;

#ifdef LITEVERSION
	LJAccount *account;
	
	UIBarButtonItem *accountButton;
#endif
}

@property (nonatomic, retain) IBOutlet UITabBarController *tabBar;
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

@property (nonatomic, retain) IBOutlet PostSummaryCell *templateCell;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *newPostOther;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *postButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshPostsButton;

@property (nonatomic, retain) IBOutlet id<AccountViewControllerDataSource> dataSource;

@property (nonatomic, retain) IBOutlet UIViewController *previousController;
@property (nonatomic, retain) IBOutlet UIViewController *postEditorController;
@property (nonatomic, retain) IBOutlet UIViewController *postViewController;
@property (nonatomic, retain) IBOutlet UIViewController *friendsTabController;
@property (nonatomic, retain) IBOutlet UIViewController *postEditorTabController;

@property (nonatomic, retain) IBOutlet UIViewController *accountEditor;

- (IBAction) goToUpdate;
- (IBAction) refreshPosts:(id) sender;

- (void) addNewOrUpdateWithPosts:(NSArray *)events forAccount:(LJAccount *)account;
- (NSArray *) requestPostsFromServerForAccount:(LJAccount *)account lastSync:(NSDate *)lastSync skip:(NSUInteger)skip items:(NSUInteger)items;

#ifdef LITEVERSION
- (LJAccount *)loadAccount;
- (void)editAccount;
- (void)saveAccount;
#endif

@end


@protocol AccountViewControllerDataSource<NSObject>

@optional
	- (LJAccount *)selectedAccountForAccountViewController:(AccountViewController *)accountViewController;

@end
