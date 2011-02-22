//
//  AccountManager.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.01.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "StateInfo.h"
#import "AccountStateInfo.h"
#import "FriendsPageFilter.h"

#define accountManager [AccountManager sharedAccountManager]

@class LJAccount, PostEditorController;

@interface AccountManager : NSObject {
	NSMutableArray *accounts;	
	StateInfo *stateInfo;
	
	NSMutableArray *postEditors;
}

+ (AccountManager *)sharedAccountManager;

// kontu pārvaldīšana
@property (readonly) NSArray *accounts;
- (void)loadAccounts;
- (void)storeAccounts;
- (BOOL)accountExists:(NSString *)key;
- (void)addAccount:(LJAccount *)account;
- (void)removeAccount:(LJAccount *)account;
- (void)moveAccountFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (void)sendReport;

// stāvokļa pārvaldīšana
@property (readonly) StateInfo *stateInfo;
- (void)loadStateInfo;
- (void)storeStateInfo;

@end
