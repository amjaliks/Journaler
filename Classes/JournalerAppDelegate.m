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
#import "HouseAdManager.h"

#import "AccountsViewController.h"
#import "SelfAdViewController.h"

@implementation JournalerAppDelegate

@synthesize reporter;
@synthesize model;
@synthesize userPicCache;

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	// sagatavojam satistikas savācējmoduli
#ifndef LITEVERSION
	NSString *appUID = @"tM7hdncHys";
#else
	NSString *appUID = @"LrAKgAl3bA";
#endif
	NSURL *reportURL = [NSURL URLWithString:@"http://tomcat.keeper.lv/anl/report"];
	reporter = [[ALReporter alloc] initWithAppUID:appUID reportURL:reportURL];
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	
	model = [[Model alloc] init];
	userPicCache = [[UserPicCache alloc] init];
	
	// noklusēti iestatījumi
	registerUserDefaults();
	
	[[AccountManager sharedManager] loadAccounts];
	[[AccountManager sharedManager] loadAccountStateInfo];
	
	// atveram kontu sarakstu
	accountsViewController = [[AccountsViewController alloc] initWithNibName:@"AccountsViewController" bundle:nil];
	
	navigationController = [[UINavigationController alloc] initWithRootViewController:accountsViewController];
	
	NSString *accountKey = [[AccountManager sharedManager] openedAccount];
	if (accountKey) {
		LJAccount *account = [[AccountManager sharedManager] accountForKey:accountKey];
		if (account) {
			[accountsViewController view];
			[accountsViewController openAccount:account animated:NO];
		}
	}
	
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
			
			nextSelfAdShowTime = [NSDate dateWithTimeIntervalSinceNow:(24.0f * 3600.0f)];
			[NSKeyedArchiver archiveRootObject:nextSelfAdShowTime toFile:nextSelfAdShowTimePath];
		}
	} else {
		nextSelfAdShowTime = [NSDate dateWithTimeIntervalSinceNow:(24.0f * 3600.0f)];
		[NSKeyedArchiver archiveRootObject:nextSelfAdShowTime toFile:nextSelfAdShowTimePath];
	}
#endif
	
	// tiek parādīta reklāma 
	[[HouseAdManager houseAdManager] showAd:navigationController];
	
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {	
	[model saveAll];
	[[AccountManager sharedManager] storeAccountStateInfo];
	
	[accountsViewController release];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[[AccountManager sharedManager] storeAccountStateInfo];
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

