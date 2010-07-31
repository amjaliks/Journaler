//
//  AccountTabBarController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.20.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AccountsViewController.h"
#import "PostEditorController.h"
#import "AccountProvider.h"

@class LJAccount, FriendsPageController, LJFriendsPageController, WebFriendsPageController, AccountsViewController;

@interface AccountTabBarController : UITabBarController <UITabBarControllerDelegate, AccountProvider> {
	IBOutlet AccountsViewController *accountsViewController;
	
	LJAccount *previousAccount;
	
	FriendsPageController *friendsPageController;
	PostEditorController *postEditorController;
	
	LJFriendsPageController *ljFriendsPageController;
	NSMutableDictionary *webFriendsPageControllerCache;
}

@property (readonly) FriendsPageController *friendsPageController;
@property (readonly) PostEditorController *postEditorController;

- (LJFriendsPageController *)ljFriendsPageController;
- (WebFriendsPageController *)webFriendsPageControllerForAccount:(LJAccount *)account;
- (void)setViewControllersForAccount:(LJAccount *)account;
- (void)setNavigationItemForViewController:(UIViewController *)viewController;
- (void)restoreState;
#ifdef LITEVERSION
- (void)showAd;
#endif

@end
