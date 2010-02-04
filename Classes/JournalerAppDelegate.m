//
//  JournalerAppDelegate.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.01.
//  Copyright A25 2009. All rights reserved.
//

#import "JournalerAppDelegate.h"
#import "ALReporter.h"
#import "WebViewController.h"
#import "Settings.h"
#import "AccountManager.h"
#import "LiveJournal.h"

#ifndef LITEVERSION
	#import "AccountsViewController.h"
#else
	#import "AccountTabBarController.h"
#endif

@implementation JournalerAppDelegate

@synthesize reporter;
@synthesize model;
@synthesize userPicCache;

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
#ifndef LITEVERSION
	NSString *appUID = @"tM7hdncHys"; // pilnā versija
#else
	NSString *appUID = @"LrAKgAl3bA"; // lite versija
#endif
	reporter = [[ALReporter alloc] initWithAppUID:appUID reportURL:[NSURL URLWithString:@"http://tomcat.keeper.lv/anldev2/report"]];	
    
	model = [[Model alloc] init];
	userPicCache = [[UserPicCache alloc] init];
	
	// noklusēti iestatījumi
	registerUserDefaults();
	
	[[AccountManager sharedManager] loadAccounts];
	[[AccountManager sharedManager] loadScreenState];
	
#ifndef LITEVERSION
	rootViewController = [[AccountsViewController alloc] initWithNibName:@"AccountsViewController" bundle:nil];
#else
	rootViewController = [[AccountTabBarController alloc] initWithAccount:[[AccountManager sharedManager] account]];
#endif
	
	navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	
#ifndef LITEVERSION
	NSString *accountKey = [[AccountManager sharedManager] openedAccount];
	if (accountKey) {
		LJAccount *account = [[AccountManager sharedManager] accountForKey:accountKey];
		if (account) {
			[rootViewController view];
			[rootViewController openAccount:account animated:NO];
		}
	}
#endif
	
	[window addSubview:navigationController.view];
	
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {	
	[model saveAll];
	[[AccountManager sharedManager] storeScreenState];
	
	[rootViewController release];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[reporter release];

	[model release];
	[userPicCache release];
	[webViewController release];
	
	[navigationController release];
	[window release];
	
	[super dealloc];
}

- (WebViewController *)webViewController {
	if (!webViewController) {
		webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
	}
	return webViewController;
}

@end

