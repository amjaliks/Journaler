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

@implementation FriendsPageController

@synthesize friendsPageFilter;

- (id)initWithAccount:(LJAccount *)aAccount {
    if (self = [super initWithNibName:@"FriendsPageController" bundle:nil]) {
		account = [aAccount retain];
		friendsPageFilter = [[AccountManager sharedManager] stateInfoForAccount:account.title].friendsPageFilter;
		
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
	
	// stāvokļa josla
	statusLineView.frame = CGRectMake(0, self.view.frame.size.height - 24, self.view.frame.size.width, 24);
	
	// virsraksta skatījums2
	UIView *titleView = [[FriendsPageTitleView alloc] initWithTarget:self action:@selector(openFilter:) interfaceOrientation:self.interfaceOrientation];
	self.navigationItem.titleView = titleView;
	[titleView release];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[AccountManager sharedManager] stateInfoForAccount:account.title].openedScreen = OpenedScreenFriendsPage;
	
	statusLineView.frame = CGRectMake(0, self.view.frame.size.height - 24, self.view.frame.size.width, 24);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIDeviceOrientationPortrait || UIDeviceOrientationIsLandscape(interfaceOrientation);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	// stāvokļa josla
	statusLineView.frame = CGRectMake(0, self.view.frame.size.height - 24, self.view.frame.size.width, 24);
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
- (void) showStatusLine {
	@synchronized (statusLineView) {
		if (!statusLineShowed) {
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			[self.view addSubview:statusLineView];
			
			[pool release];
		}
		statusLineShowed++;
	}
}

// paslēpj stāvokļa joslu
- (void) hideStatusLine {
	@synchronized (statusLineView) {
		statusLineShowed--;
		if (!statusLineShowed) {
			[statusLineView removeFromSuperview];
		}
	}
}

- (void)dealloc {
	[account release];
	[super dealloc];
}


@end
