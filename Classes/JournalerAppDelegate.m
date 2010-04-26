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
	#import "SelfAdViewController.h"
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
	
#ifndef DEBUG
	NSURL *reportURL = [NSURL URLWithString:@"http://tomcat.keeper.lv/anl/report"];
#else
	NSURL *reportURL = [NSURL URLWithString:@"http://localhost:8080/anl/report"];
#endif
	
	reporter = [[ALReporter alloc] initWithAppUID:appUID reportURL:reportURL];
	
	model = [[Model alloc] init];
	userPicCache = [[UserPicCache alloc] init];
	
	// noklusēti iestatījumi
	registerUserDefaults();
	
	[[AccountManager sharedManager] loadAccounts];
	[[AccountManager sharedManager] loadAccountStateInfo];
	
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
	
#ifdef LITEVERSION
	NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	NSString *nextSelfAdShowTimePath = [docDirPath stringByAppendingPathComponent:@"nextSelfAdShowTime.bin"];
	NSDate *nextSelfAdShowTime = [NSKeyedUnarchiver unarchiveObjectWithFile:nextSelfAdShowTimePath];
	
	if (nextSelfAdShowTime) {
		if ([nextSelfAdShowTime compare:[NSDate date]] != NSOrderedDescending) {
			SelfAdViewController *selfAdViewController = [[SelfAdViewController alloc] initWithNibName:@"SelfAdViewController" bundle:nil];
			[navigationController presentModalViewController:selfAdViewController animated:NO];
			[selfAdViewController startCountDown];
			[selfAdViewController release];
			
			nextSelfAdShowTime = [NSDate dateWithTimeIntervalSinceNow:(7.0f * 24.0f * 3600.0f)];
			[NSKeyedArchiver archiveRootObject:nextSelfAdShowTime toFile:nextSelfAdShowTimePath];
		}
	} else {
		nextSelfAdShowTime = [NSDate dateWithTimeIntervalSinceNow:(24.0f * 3600.0f)];
		[NSKeyedArchiver archiveRootObject:nextSelfAdShowTime toFile:nextSelfAdShowTimePath];
	}
#endif
	
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {	
	[model saveAll];
	[[AccountManager sharedManager] storeAccountStateInfo];
	
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

