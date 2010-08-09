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
#import "LJManager.h"
#import "HAManager.h"

#import "AccountsViewController.h"

@implementation JournalerAppDelegate

@synthesize webViewController;
@synthesize reporter;

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
	
	// noklusēti iestatījumi
	registerUserDefaults();
	
	[accountManager loadAccounts];
	[accountsViewController restoreState];
	
	// reklāma
	houseAdManager.rootViewController = navigationController;
	[houseAdManager prepareAd];

	// ja ir izveidots kaut viens konts, tiek parādīta reklāma 
	if ([accountManager.accounts count] && houseAdManager.showAdOnStart) {
		[houseAdManager showAd];
	}
	
	[window addSubview:navigationController.view];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {	
	[model saveAll];
	[accountManager storeStateInfo];
	
	[accountsViewController release];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[accountManager storeStateInfo];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[ljManager didReceiveMemoryWarning];
	[userPicCache didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[reporter release];

	[navigationController release];
	[window release];
	
	[super dealloc];
}

@end

