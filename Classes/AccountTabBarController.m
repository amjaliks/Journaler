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
#import "LiveJournal.h"

@implementation AccountTabBarController

- (id) initWithAccount:(LJAccount *)aAccount {
	if (self = [super init]) {
		account = [aAccount retain];
		
		// virsraksts
		self.navigationItem.title = account.user;
		
		FriendsPageController *friendList = [@"livejournal.com" isEqual:account.server] ? [[LJFriendsPageController alloc] initWithAccount:account] : [[WebFriendsPageController alloc] initWithAccount:account];
		NSArray *arrays = [[NSArray alloc] initWithObjects:friendList, nil];
		self.viewControllers = arrays;
		[friendList release];
		[arrays release];
	}
	return self;
}

- (void) viewDidLoad {
	[super viewDidLoad];
	
#ifdef LITEVERSION 
	UIBarButtonItem *accountButton = [[UIBarButtonItem alloc] initWithTitle:@"Account" style:UIBarButtonItemStyleBordered target:self action:@selector(editAccount)];
	self.navigationItem.leftBarButtonItem = accountButton;
	[accountButton release];
#endif
	
}

#ifdef LITEVERSION

#pragma mark Account Editor Controller DataSource metodes

- (void)editAccount {
	AccountEditorController  *accountEditorController = [[AccountEditorController alloc] initWithNibName:@"AccountEditorController" bundle:nil];
	accountEditorController.dataSource = self;
	accountEditorController.delegate = self;
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:accountEditorController];
	
	[self presentModalViewController:navigationController animated:YES];
	
	[navigationController release];
	[accountEditorController release];
}

- (LJAccount *)selectedAccount {
	return account;
}

- (BOOL)isDublicateAccount:(NSString *)title {
	return NO;
}

- (BOOL)hasNoAccounts {
	return account == nxil;
}

- (void)saveAccount:(LJAccount *)newAccount {
	[APP_DELEGATE saveAccount:newAccount];

	if (account) {
		if (![account.title isEqualToString:newAccount.title]) {
			// iepriekš ievadītais konts atšķiras no jaunā, tad tīram laukā kešu
			[APP_MODEL deleteAllPostsForAccount:account.title];
			// pārlādējam arī saskarni
			FriendsPageController *friendList = [@"livejournal.com" isEqual:newAccount.server] ? [[LJFriendsPageController alloc] initWithAccount:newAccount] : [[WebFriendsPageController alloc] initWithAccount:newAccount];
			NSArray *arrays = [[NSArray alloc] initWithObjects:friendList, nil];
			self.viewControllers = arrays;
			[friendList release];
			[arrays release];
		}
		[account release];
	}
	account = [newAccount retain];
	
}

#endif

#pragma mark Atmiņas pārvaldība

- (void) dealloc {
	[account release];
	
	[super dealloc];
}


@end
