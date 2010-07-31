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

- (void)viewDidLoad {
	webFriendsPageControllerCache = [[NSMutableDictionary alloc] init];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	[webFriendsPageControllerCache release];
	webFriendsPageControllerCache = nil;
}

- (void)setViewControllersForAccount:(LJAccount *)account {
	if (previousAccount != account) {
		previousAccount = account;
		
		if ([account supports:ServerFeatureFriendsPage]) {
			friendsPageController = [self ljFriendsPageController];
		} else {
			friendsPageController = [self webFriendsPageControllerForAccount:account];
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
			ljFriendsPageController = [[LJFriendsPageController alloc] initWithNibName:@"LJFriendsPageController" bundle:nil];
			ljFriendsPageController.accountProvider = self;
		}
		return ljFriendsPageController;
	}
}

- (WebFriendsPageController *)webFriendsPageControllerForAccount:(LJAccount *)account {
	@synchronized (self) {
		WebFriendsPageController *webFriendsPageController = [[webFriendsPageControllerCache objectForKey:account] retain];
		if (!webFriendsPageController) {
			webFriendsPageController = [[WebFriendsPageController alloc] initWithNibName:@"FriendsPageController" bundle:nil];
			webFriendsPageController.accountProvider = self;
			[webFriendsPageControllerCache setObject:webFriendsPageController forKey:account];
		}
		return [webFriendsPageController autorelease];
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
	[self setViewControllersForAccount:self.account];
	[self.navigationItem.titleView setNeedsLayout];
	[super viewWillAppear:animated];
}

- (void)restoreState {
	[self view];
	[self setViewControllersForAccount:self.account];
	[friendsPageController restoreState];
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
	[ljFriendsPageController release];
	ljFriendsPageController = nil;
	[postEditorController release];
	postEditorController = nil;
	[webFriendsPageControllerCache removeAllObjects];
	
	[super didReceiveMemoryWarning];	
}

- (void)dealloc {
	[ljFriendsPageController release];
	[webFriendsPageControllerCache release];
	[postEditorController release];

	[super dealloc];
}

@end
