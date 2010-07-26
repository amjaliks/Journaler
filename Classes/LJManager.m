//
//  LJManager.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.26.
//  Copyright 2010 A25. All rights reserved.
//

#import "LJManager.h"
#import "LiveJournal.h"

#import "JournalerAppDelegate.h"


LJManager *ljManager;


@implementation LJManager

- (void)loadPostsForAccount:(LJAccount *)account {
	@synchronized (account) {
		if (![self loadingPostsForAccount:account] && ![loadedPosts objectForKey:account]) {
			[loadingPosts addObject:account];
			[self performSelectorInBackground:@selector(backgroundLoadPostsForAccount:) withObject:account];
		} else {
			[notificationCenter postNotificationName:LJManagerStepCompletedNotification 
											object:self 
											userInfo:[NSDictionary dictionaryWithObject:account forKey:@"account"]];
		}
	}
}

- (BOOL)loadingPostsForAccount:(LJAccount *)account {

	return [loadingPosts containsObject:account];
}

- (NSArray *)loadedPostsForAccount:(LJAccount *)account {
	return [loadedPosts objectForKey:account];
}

- (void)backgroundLoadPostsForAccount:(LJAccount *)account {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// ielādējam ierakstus no keša
	NSMutableArray *posts = [[model findPostsByAccount:account.title] mutableCopy];
	[loadedPosts setObject:posts forKey:account];
	
	@synchronized (account) {
		[loadingPosts removeObject:account];
	}
	
	// izsūtam paziņojumu
	[notificationCenter postNotificationName:LJManagerStepCompletedNotification 
									object:self 
									userInfo:[NSDictionary dictionaryWithObject:account forKey:@"account"]];
	
	[pool release];
}

#pragma mark -
#pragma mark Singleton metodes

+ (LJManager *)manager {
	@synchronized (self) {
		if (ljManager == nil) {
			ljManager = [[super allocWithZone:nil] init];
		}
	}
	return ljManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self manager] retain];
}

- (id)init {
	if (self = [super init]) {
		model = ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate]).model;
		notificationCenter = [NSNotificationCenter defaultCenter];
		
		loadingPosts = [[NSMutableSet alloc] init];
		loadedPosts = [[NSMutableDictionary alloc] init];
	}
	return self;
}


- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
