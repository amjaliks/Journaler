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

@implementation AccountTabBarController

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
	UIBarButtonItem *accountButton = [[UIBarButtonItem alloc] initWithTitle:@"Account" style:UIBarButtonItemStyleBordered target:self action:@selector(editAccount)];
	self.navigationItem.leftBarButtonItem = accountButton;
	[accountButton release];
#endif
	
}

- (void) setViewControllersForAccount:(LJAccount *)newAccount {
	FriendsPageController *friendList = [@"livejournal.com" isEqual:newAccount.server] ? [[LJFriendsPageController alloc] initWithAccount:account] : [[WebFriendsPageController alloc] initWithAccount:newAccount];
	self.navigationItem.rightBarButtonItem = friendList.navigationItem.rightBarButtonItem;
	
	PostEditorController *postEditorController = [[PostEditorController alloc] initWithNibName:@"PostEditorController" bundle:nil];
	postEditorController.dataSource = self;
	
	NSArray *arrays = [[NSArray alloc] initWithObjects:friendList, postEditorController, nil];
	self.viewControllers = arrays;
	
	[friendList release];
	[postEditorController release];
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
