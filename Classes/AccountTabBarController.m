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

@implementation AccountTabBarController

@synthesize friendsPageController;

- (void) setViewControllersForAccount:(LJAccount *)newAccount {
	[friendsPageController release];
	friendsPageController = [@"livejournal.com" isEqual:newAccount.server] ? [[LJFriendsPageController alloc] initWithAccount:newAccount] : [[WebFriendsPageController alloc] initWithAccount:newAccount];
	self.navigationItem.rightBarButtonItem = friendsPageController.navigationItem.rightBarButtonItem;
	
	if (postEditorController) {
		[postEditorController release];
	}
	postEditorController = [[PostEditorController alloc] initWithAccount:newAccount];
	postEditorController.dataSource = self;
	
	NSArray *arrays = [[NSArray alloc] initWithObjects:friendsPageController, postEditorController, nil];
	self.viewControllers = arrays;
	self.selectedIndex = [[AccountManager sharedManager].stateInfo stateInfoForAccount:newAccount].openedScreen == OpenedScreenNewPost ? 1 : 0;

	[self setNavigationItemForViewController:self.selectedViewController];

	[arrays release];
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
		}
		return ljFriendsPageController;
	}
}

#pragma mark -
#pragma mark Tab Bar Controller Delegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	[self setNavigationItemForViewController:viewController];
	
	NSUInteger value = postEditorController == viewController ? OpenedScreenNewPost : OpenedScreenFriendsPage;
	[accountsViewController.accountManager.stateInfo stateInfoForAccount:accountsViewController.selectedAccount].openedScreen = value;
	
}

- (LJAccount *)selectedAccount {
	return accountsViewController.selectedAccount;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (previousAccount != accountsViewController.selectedAccount) {
		[self setViewControllersForAccount:accountsViewController.selectedAccount];
		previousAccount = accountsViewController.selectedAccount;
	}
	
	[self.navigationItem.titleView setNeedsLayout];
}

#pragma mark -
#pragma mark Atmiņas pārvaldība

- (void) dealloc {
	[friendsPageController release];
	[postEditorController release];

	[super dealloc];
}

@end
