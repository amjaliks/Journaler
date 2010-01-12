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

@implementation AccountTabBarController

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
	FriendsPageController *friendList = [@"livejournal.com" isEqual:newAccount.server] ? [[LJFriendsPageController alloc] initWithAccount:newAccount] : [[WebFriendsPageController alloc] initWithAccount:newAccount];
	self.navigationItem.rightBarButtonItem = friendList.navigationItem.rightBarButtonItem;
	
	if (postEditorController) {
		[postEditorController release];
	}
	postEditorController = [[PostEditorController alloc] initWithAccount:newAccount];
	postEditorController.dataSource = self;
	
	NSArray *arrays = [[NSArray alloc] initWithObjects:friendList, postEditorController, nil];
	self.viewControllers = arrays;
	self.selectedIndex = newAccount.selectedTab;
	
	[friendList release];
	[arrays release];
}

#pragma mark Tab Bar Controller Delegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	self.navigationItem.rightBarButtonItem = viewController.navigationItem.rightBarButtonItem;
}

- (LJAccount *)selectedAccount {
	return account;
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
	AccountEditorController  *accountEditorController = [[AccountEditorController alloc] initWithNibName:@"AccountEditorController" bundle:nil];
	accountEditorController.dataSource = self;
	accountEditorController.delegate = self;
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:accountEditorController];
	
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
	[APP_DELEGATE saveAccount:newAccount];

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
	
}

#endif

#pragma mark Atmiņas pārvaldība

- (void) dealloc {
	[postEditorController release];

	[account release];
	
#ifdef LITEVERSION
	[accountButton release];
#endif
	
	[super dealloc];
}

- (void)saveState {
	[postEditorController saveState];
	account.selectedTab = self.selectedIndex;
	
#ifdef LITEVERSION
	[APP_DELEGATE saveAccount:account];
#endif
}

@end
