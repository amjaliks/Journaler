//
//  FriendsPageController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.24.
//  Copyright 2009 A25. All rights reserved.
//

#import "FriendsPageController.h"

#import <QuartzCore/QuartzCore.h>

#import "JournalerAppDelegate.h"
#import "LiveJournal.h"
#import "AccountManager.h"
#import "FriendsPageTitleView.h"
#import "FilterOptionsController.h"
#import "BannerViewController.h"
#import "AccountTabBarController.h"

@implementation FriendsPageController

@synthesize accountProvider;
@synthesize friendsPageFilter;

- (id)initWithNibName:(NSString *)nibFile bundle:(NSBundle *)bundle {
    if (self = [super initWithNibName:nibFile bundle:bundle]) {
		// cilnes bildīte
		UIImage *image = [UIImage imageNamed:@"friends.png"];
		UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Friends", nil) image:image tag:0];
		self.tabBarItem = tabBarItem;
		[tabBarItem release];

    	refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
		self.navigationItem.rightBarButtonItem = refreshButtonItem;
		self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Friends", @"Friends") style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	}
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// aktivitātes indikators
	[spinnerItem setCustomView:spinnerView];
	
	// virsraksta skats
	titleView = [[FriendsPageTitleView alloc] initWithTarget:self action:@selector(openFilter:) interfaceOrientation:self.interfaceOrientation];
	self.navigationItem.titleView = titleView;
}

- (void)viewDidUnload {
	// virsraksta skats
	self.navigationItem.titleView = nil;
	
	[titleView release];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	friendsPageFilter = self.accountStateInfo.friendsPageFilter;
	titleView.filterLabel.text = [friendsPageFilter title];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.accountStateInfo.openedScreen = OpenedScreenFriendsPage;
}

- (UIView *)mainView {
	return nil;
}

#ifndef LITEVERSION
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIDeviceOrientationPortrait || UIDeviceOrientationIsLandscape(interfaceOrientation);
}
#endif

#pragma mark -
#pragma mark AccountProvider

- (LJAccount *)account {
	return accountProvider.account;
}

- (AccountStateInfo *)accountStateInfo {
	return accountProvider.accountStateInfo;
}

- (AccountManager *)accountManager {
	return accountProvider.accountManager;
}

#pragma mark -
#pragma mark Pogas

- (void)refresh {}

- (void)openFilter:(id)sender {
	UIViewController *viewController = [[FilterOptionsController alloc] initWithFriendsPageController:self];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];
	[viewController release];
}

#pragma mark -
#pragma mark Stāvokļa josla

// parāda stāvokļa joslu
- (void) showActivityIndicator {
	@synchronized (spinnerItem) {
		if (!spinnerVisible) {
			self.navigationItem.rightBarButtonItem = spinnerItem;
			if (self == self.tabBarController.selectedViewController) {
				self.tabBarController.navigationItem.rightBarButtonItem = spinnerItem;
			}
		}
		spinnerVisible++;
	}
}

// paslēpj stāvokļa joslu
- (void) hideActivityIndicator {
	@synchronized (spinnerItem) {
		spinnerVisible--;
		if (!spinnerVisible) {
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

			self.navigationItem.rightBarButtonItem = refreshButtonItem;
			if (self == self.tabBarController.selectedViewController) {
				self.tabBarController.navigationItem.rightBarButtonItem = refreshButtonItem;
			}
			
			[pool release];
		}
	}
}

- (void)filterFriendsPage {};

- (void)dealloc {
	[super dealloc];
}

@end
