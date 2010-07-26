//
//  StateInfo.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.23.
//  Copyright 2010 A25. All rights reserved.
//

#import "StateInfo.h"

#define kKeyOpenedAccountIndex @"openedAccountIndex"
#define kKeyAccountsStateInfo @"accountsStateInfo"

@implementation StateInfo

@synthesize openedAccountIndex;

- (id)init {
	if (self = [super init]) {
		openedAccountIndex = kStateInfoOpenedAccountIndexNone;
		accountsStateInfo = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
	
	[accountsStateInfo release];
}

#pragma mark -

- (AccountStateInfo *)stateInfoForAccount:(LJAccount *)account {
	@synchronized (self) {
		AccountStateInfo *accountStateInfo = [[accountsStateInfo objectForKey:account.title] retain];

		if (!accountStateInfo) {
			accountStateInfo = [[AccountStateInfo alloc] init];
			[accountsStateInfo setObject:accountStateInfo forKey:account.title];
		}
		
		return accountStateInfo;
	}
}

- (void)removeStateInfoForAccount:(LJAccount *)account {
	[accountsStateInfo removeObjectForKey:account];
}

#pragma mark -
#pragma mark NSCoder metodes

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [self init]) {
		// atvērtais konts
		if ([coder containsValueForKey:kKeyOpenedAccountIndex]) openedAccountIndex = [coder decodeIntegerForKey:kKeyOpenedAccountIndex];
		// kontu stāvokli
		[accountsStateInfo addEntriesFromDictionary:[coder decodeObjectForKey:kKeyAccountsStateInfo]];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInteger:openedAccountIndex forKey:kKeyOpenedAccountIndex];
	[coder encodeObject:accountsStateInfo forKey:kKeyAccountsStateInfo];
}

@end
