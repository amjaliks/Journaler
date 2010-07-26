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

@class LJAccount, FriendsPageController, LJFriendsPageController, WebFriendsPageController;

@interface AccountTabBarController : UITabBarController <PostEditorControllerDataSource, UITabBarControllerDelegate> {
	IBOutlet AccountsViewController *accountsViewController;
	
	LJAccount *previousAccount;
	
	FriendsPageController *friendsPageController;
	PostEditorController *postEditorController;
	
	LJFriendsPageController *ljFriendsPageController;
	WebFriendsPageController *webFriendsPageController;
}

@property (readonly) FriendsPageController *friendsPageController;
@property (readonly) PostEditorController *postEditorController;

@property (readonly) LJFriendsPageController *ljFriendsPageController;
@property (readonly) WebFriendsPageController *webFriendsPageController;

- (void)setViewControllersForAccount:(LJAccount *)account;
- (void)setNavigationItemForViewController:(UIViewController *)viewController;

@end
