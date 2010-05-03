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

- (id) initWithAccount:(LJAccount *)aAccount {
	if (self = [super init]) {
		self.delegate = self;
		
		account = [aAccount retain];
		
		// virsraksts
		self.navigationItem.title = account.user;
		
		[self setViewControllersForAccount:account];
	}
	return self;
}

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
	self.selectedIndex = [[AccountManager sharedManager] stateInfoForAccount:newAccount.title].openedScreen == OpenedScreenNewPost ? 1 : 0;

	[self setNavigationItemForViewController:self.selectedViewController];

	[arrays release];
}

- (void)setNavigationItemForViewController:(UIViewController *)viewController {
	self.navigationItem.rightBarButtonItem = viewController.navigationItem.rightBarButtonItem;
	self.navigationItem.title = viewController.navigationItem.title;
	self.navigationItem.titleView = viewController.navigationItem.titleView;
	
//	NSLog(@"%f", self.navigationController.navigationBar.);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark -
#pragma mark Tab Bar Controller Delegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	[self setNavigationItemForViewController:viewController];
	
	NSUInteger value = postEditorController == viewController ? OpenedScreenNewPost : OpenedScreenFriendsPage;
	[[AccountManager sharedManager] stateInfoForAccount:account.title].openedScreen = value;
	
}

- (LJAccount *)selectedAccount {
	return account;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationItem.titleView resizeForInterfaceOrientation:self.interfaceOrientation];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[AccountManager sharedManager] setOpenedAccount:account.title];
}

#pragma mark -
#pragma mark Atmiņas pārvaldība

- (void) dealloc {
	[friendsPageController release];
	[postEditorController release];

	[account release];
	
	[super dealloc];
}

@end
