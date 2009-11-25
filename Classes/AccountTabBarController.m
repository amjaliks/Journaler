//
//  AccountTabBarController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.20.
//  Copyright 2009 A25. All rights reserved.
//

#import "AccountTabBarController.h"

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
	}
	return self;
}

#pragma mark Atmiņas pārvaldība

- (void) dealloc {
	[account release];
	
	[super dealloc];
}


@end
