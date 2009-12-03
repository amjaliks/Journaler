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
	
#ifndef LITEVERSION
	rootViewController = [[AccountsViewController alloc] initWithNibName:@"AccountsViewController" bundle:nil];
#else
	rootViewController = [[AccountTabBarController alloc] initWithAccount:[self loadAccount]];
#endif
	
	navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	
	[window addSubview:navigationController.view];
	
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {	
	[model saveAll];
	
#ifdef LITEVERSION
	[(AccountTabBarController *) rootViewController saveState];
#else
	[(AccountsViewController *) rootViewController saveState];
#endif

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
	
#ifndef LITEVERSION
	[accounts release];
#endif
	[super dealloc];
}

- (WebViewController *)webViewController {
	if (!webViewController) {
		webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
	}
	return webViewController;
}

#pragma mark Metodes darbam ar kontiem

#ifndef LITEVERSION

- (NSArray *) loadAccounts {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];
	path = [path stringByAppendingPathComponent:@"accounts.bin"];
	accounts = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	
	if (accounts) {
		accounts = [accounts mutableCopy];
	} else {
		accounts = [[NSMutableArray alloc] init];
	}
	
	return accounts;
}

- (void) saveAccounts:(NSArray *)accountsToSave {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];
	path = [path stringByAppendingPathComponent:@"accounts.bin"];
	[NSKeyedArchiver archiveRootObject:accountsToSave toFile:path];
}

- (void) saveAccounts {
	[self saveAccounts:accounts];
}

#else

- (LJAccount *)loadAccount {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];
	path = [path stringByAppendingPathComponent:@"account.bin"];
	LJAccount *account = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	return account;
}

- (void) saveAccount:(LJAccount *)account {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];
	path = [path stringByAppendingPathComponent:@"account.bin"];
	[NSKeyedArchiver archiveRootObject:account toFile:path];
}

#endif

@end

