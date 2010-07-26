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

@implementation FriendsPageController

@synthesize account;
@synthesize friendsPageFilter;

- (id)initWithAccount:(LJAccount *)aAccount {
    if (self = [super initWithNibName:@"FriendsPageController" bundle:nil]) {
		account = [aAccount retain];
		friendsPageFilter = [[AccountManager sharedManager].stateInfo stateInfoForAccount:account].friendsPageFilter;
		
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
	titleView.filterLabel.text = [friendsPageFilter title];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[AccountManager sharedManager].stateInfo stateInfoForAccount:account].openedScreen = OpenedScreenFriendsPage;
	
#ifdef LITEVERSION
	[[BannerViewController controller] addBannerToView:self.view resizeView:friendsPageView];
#endif
}

#ifndef LITEVERSION
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIDeviceOrientationPortrait || UIDeviceOrientationIsLandscape(interfaceOrientation);
}
#endif

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
			self.navigationItem.rightBarButtonItem = refreshButtonItem;
			if (self == self.tabBarController.selectedViewController) {
				self.tabBarController.navigationItem.rightBarButtonItem = refreshButtonItem;
			}
		}
	}
}

- (void)filterFriendsPage {};

- (void)dealloc {
	[account release];
	[super dealloc];
}

@end
