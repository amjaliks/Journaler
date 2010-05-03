//
//  AccountTabBarController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.20.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PostEditorController.h"

@class LJAccount, FriendsPageController;

@interface AccountTabBarController : UITabBarController <PostEditorControllerDataSource, UITabBarControllerDelegate> {
	LJAccount *account;
	
	FriendsPageController *friendsPageController;
	PostEditorController *postEditorController;
}

@property (readonly) FriendsPageController *friendsPageController;

- (id)initWithAccount:(LJAccount *)account;
- (void)setViewControllersForAccount:(LJAccount *)account;
- (void)setNavigationItemForViewController:(UIViewController *)viewController;

@end
