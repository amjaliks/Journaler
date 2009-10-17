//
//  JournalerAppDelegate.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.01.
//  Copyright A25 2009. All rights reserved.
//

#import "JournalerAppDelegate.h"
//#import "RootViewController.h"


@implementation JournalerAppDelegate

@synthesize model;

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
	model = [[Model alloc] init];
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {	
	[model saveAll];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[model release];
	
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

