//
//  AccountTabBarController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.20.
//  Copyright 2009 A25. All rights reserved.
//

#import "AccountTabBarController.h"

#import "JournalerAppDelegate.h"
#import "LJFriendsPageController.h"
#import "WebFriendsPageController.h"
#import "FriendsPageController.h"
#import "PostEditorController.h"
#import "LiveJournal.h"
#import "Macros.h"
#import "AccountManager.h"
#import "ALReporter.h"
#import "UIViewAdditions.h"
#import "BannerViewController.h"

@implementation AccountTabBarController

@synthesize friendsPageController;

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)setViewControllersForAccount:(LJAccount *)account {
	if (previousAccount != account) {
		previousAccount = account;
		
		if ([account supports:ServerFeatureFriendsPage]) {
			friendsPageController = self.ljFriendsPageController;
		} else {
			friendsPageController = self.webFriendsPageController;
		}
		
		self.viewControllers = [NSArray arrayWithObjects:friendsPageController, self.postEditorController, nil];
		self.selectedIndex = self.accountStateInfo.openedScreen == OpenedScreenNewPost ? 1 : 0;
		
		[self setNavigationItemForViewController:self.selectedViewController];
	}
}

- (void)setNavigationItemForViewController:(UIViewController *)viewController {
	self.navigationItem.backBarButtonItem = viewController.navigationItem.backBarButtonItem;
	self.navigationItem.rightBarButtonItem = viewController.navigationItem.rightBarButtonItem;
	self.navigationItem.title = viewController.navigationItem.title;
	self.navigationItem.titleView = viewController.navigationItem.titleView;
}

#pragma mark -
#pragma mark Īpašības

- (LJFriendsPageController *)ljFriendsPageController {
	@synchronized (self) {
		if (!ljFriendsPageController) {
			ljFriendsPageController = [[LJFriendsPageController alloc] initWithNibName:@"FriendsPageController" bundle:nil];
			ljFriendsPageController.accountProvider = self;
		}
		return ljFriendsPageController;
	}
}

- (WebFriendsPageController *)webFriendsPageController {
	@synchronized (self) {
		if (!webFriendsPageController) {
			webFriendsPageController = [[WebFriendsPageController alloc] initWithNibName:@"FriendsPageController" bundle:nil];
			webFriendsPageController.accountProvider = self;
		}
		return webFriendsPageController;
	}
}

- (PostEditorController *)postEditorController {
	@synchronized (self) {
		if (!postEditorController) {
			postEditorController = [[PostEditorController alloc] initWithNibName:@"PostEditorController" bundle:nil];
			postEditorController.accountProvider = self;
		}
		return postEditorController;
	}
}

#pragma mark AccountProvider

- (AccountStateInfo *)accountStateInfo {
	return accountsViewController.accountStateInfo;
}

- (AccountManager *)accountManager {
	return accountsViewController.accountManager;
}

#pragma mark -
#pragma mark Tab Bar Controller Delegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	[self setNavigationItemForViewController:viewController];
	
	NSUInteger value = postEditorController == viewController ? OpenedScreenNewPost : OpenedScreenFriendsPage;
	self.accountStateInfo.openedScreen = value;
	
#ifdef LITEVERSION
	[self showAd];
#endif
}

- (LJAccount *)account {
	return accountsViewController.account;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self setViewControllersForAccount:self.account];
	[self.navigationItem.titleView setNeedsLayout];
}

#ifdef LITEVERSION
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self showAd];
}

- (void)showAd {
	if (self.selectedIndex == 0) {
		[[BannerViewController controller] 
			addBannerToView:self.selectedViewController.view 
			resizeView:((FriendsPageController *)self.selectedViewController).mainView];
	}
}
#endif

#pragma mark -
#pragma mark Atmiņas pārvaldība

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	
	[ljFriendsPageController release];
	ljFriendsPageController = nil;
	[webFriendsPageController release];
	webFriendsPageController = nil;
	[postEditorController release];
	postEditorController = nil;
}

- (void)dealloc {
	[ljFriendsPageController release];
	[webFriendsPageController release];
	[postEditorController release];

	[super dealloc];
}

@end
