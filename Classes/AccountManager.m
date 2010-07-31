//
//  AccountManager.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.01.
//  Copyright 2010 A25. All rights reserved.
//

#import "AccountManager.h"
#import "Macros.h"
#import "LiveJournal.h"
#import "PostEditorController.h"
#import "ALReporter.h"
#import "JournalerAppDelegate.h"
#import "LJManager.h"
#import "SynthesizeSingleton.h"

#define kAccountsFileName @"accounts.bin"
#define kStateInfoFileName @"stateinfo"

@implementation AccountManager

#pragma mark Kontu pārvaldīšana

@synthesize accounts;

- (void)loadAccounts {
	// nolasam kontu sarakstu
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];
	path = [path stringByAppendingPathComponent:kAccountsFileName];
	accounts = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	
	if (accounts) {
		accounts = [accounts mutableCopy];
	} else {
		accounts = [[NSMutableArray alloc] init];
	}
}

- (void)storeAccounts {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];
	path = [path stringByAppendingPathComponent:kAccountsFileName];
	[NSKeyedArchiver archiveRootObject:accounts toFile:path];
}

- (BOOL)accountExists:(NSString *)key {
	for (LJAccount *account in accounts) {
		if ([account.title isEqualToString:key]) {
			return YES;
		}
	}
	return NO;
}

- (void)addAccount:(LJAccount *)account {
	[accounts addObject:account];
	[self storeAccounts];
	
	[self sendReport];
}

- (void)removeAccount:(LJAccount *)account {
	[ljManager removePostsForAccount:account];
	[stateInfo removeStateInfoForAccount:account];
	[accounts removeObject:account];
	[self storeStateInfo];
	[self storeAccounts];
	
	[self sendReport];
}

- (void)moveAccountFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
	LJAccount *account = [[accounts objectAtIndex:fromIndex] retain];
	[accounts removeObjectAtIndex:fromIndex];
	[accounts insertObject:account atIndex:toIndex];
	[account release];
	
	[self storeAccounts];
}

#pragma mark Ekrānu stāvokļa pārvaldīšana

- (StateInfo *)stateInfo {
	@synchronized (self) {
		if (!stateInfo) {
			[self loadStateInfo];
		}
		return stateInfo;
	}
}

- (void)loadStateInfo {
	NSString *path = [appCachesDir stringByAppendingPathComponent:kStateInfoFileName];
	stateInfo = [[NSKeyedUnarchiver unarchiveObjectWithFile:path] retain];
	
	if (!stateInfo) {
		stateInfo = [[StateInfo alloc] init];
	}
}

- (void)storeStateInfo {
	for(PostEditorController *controller in postEditors) {
		[controller saveState];
	}

	NSString *path = [appCachesDir stringByAppendingPathComponent:kStateInfoFileName];
	[NSKeyedArchiver archiveRootObject:stateInfo toFile:path];
}

- (void)registerPostEditorController:(PostEditorController *)controller {
	[postEditors addObject:controller];
}

#pragma mark Singleton metodes

- (id)init {
	self = [super init];
	if (self != nil) {
		stateInfo = nil;
		postEditors = [[NSMutableArray alloc] init];
	}
	return self;
}

SYNTHESIZE_SINGLETON_FOR_CLASS(AccountManager)

#pragma mark -

- (void) sendReport {
	ALReporter *reporter = ((JournalerAppDelegate *)[UIApplication sharedApplication].delegate).reporter;
	[reporter setInteger:[accounts count] forProperty:@"account_count"];
	
	NSMutableSet *servers = [[NSMutableSet alloc] init];
	for (LJAccount *account in accounts) {
		[servers addObject:account.server];
	}
	[reporter setObject:servers forProperty:@"server"];
	[servers release];
}

@end
