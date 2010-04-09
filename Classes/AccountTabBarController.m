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

@implementation AccountTabBarController

@synthesize friendsPageController;
#ifdef LITEVERSION
@synthesize accountButton;
#endif

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

- (void) viewDidLoad {
	[super viewDidLoad];
	
#ifdef LITEVERSION 
	accountButton = [[UIBarButtonItem alloc] initWithTitle:@"Account" style:UIBarButtonItemStyleBordered target:self action:@selector(editAccount)];
	self.navigationItem.leftBarButtonItem = accountButton;
#endif
	
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
	self.selectedIndex = [[AccountManager sharedManager] unsignedIntegerValueForAccount:newAccount.title forKey:kStateInfoOpenedScreenType] == OpenedScreenNewPost ? 1 : 0;
	self.navigationItem.rightBarButtonItem = self.selectedViewController.navigationItem.rightBarButtonItem;
	
	[arrays release];
}

#pragma mark Tab Bar Controller Delegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	self.navigationItem.rightBarButtonItem = viewController.navigationItem.rightBarButtonItem;
	
	NSUInteger value = postEditorController == viewController ? OpenedScreenNewPost : OpenedScreenFriendsPage;
	[[AccountManager sharedManager] setUnsignedIntegerValue:value forAccount:account.title forKey:kStateInfoOpenedScreenType];
}

- (LJAccount *)selectedAccount {
	return account;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[AccountManager sharedManager] setOpenedAccount:account.title];
}

#ifdef LITEVERSION

#pragma mark Account Editor Controller DataSource metodes

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (!account) {
		[self editAccount];
	}
}

- (void)editAccount {
	AccountEditorController *accountEditorController = [[AccountEditorController alloc] initWithNibName:@"AccountEditorController" bundle:nil];
	accountEditorController.dataSource = self;
	accountEditorController.delegate = self;
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:accountEditorController];
	
	[accountEditorController view];
	[accountEditorController setAccount:account];
	[self presentModalViewController:navigationController animated:YES];
	
	[navigationController release];
	[accountEditorController release];
}

- (BOOL)isDublicateAccount:(NSString *)title {
	return NO;
}

- (BOOL)hasNoAccounts {
	return account == nil;
}

- (void)saveAccount:(LJAccount *)newAccount {
	[[AccountManager sharedManager] storeAccount:newAccount];

	if (account) {
		if (![account.title isEqualToString:newAccount.title]) {
			// iepriekš ievadītais konts atšķiras no jaunā, tad tīram laukā kešu
			[APP_MODEL deleteAllPostsForAccount:account.title];
			// pārlādējam arī saskarni
			[self setViewControllersForAccount:newAccount];
			// virsraksts
			self.navigationItem.title = newAccount.user;
		}
		[account release];
	} else {
		[self setViewControllersForAccount:newAccount];
		self.navigationItem.title = newAccount.user;
	}
	account = [newAccount retain];
	
	[self sendReport];
}

- (void)sendReport {
	ALReporter *reporter = ((JournalerAppDelegate *)[UIApplication sharedApplication].delegate).reporter;
	[reporter setObject:account.server forProperty:@"server"];
}

#endif

#pragma mark Atmiņas pārvaldība

- (void) dealloc {
	[friendsPageController release];
	[postEditorController release];

	[account release];
	
#ifdef LITEVERSION
	[accountButton release];
#endif
	
	[super dealloc];
}

@end
