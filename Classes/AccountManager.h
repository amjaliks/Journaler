//
//  AccountManager.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.01.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kStateInfoFileName @"stateInfo.plist"
#define kStateInfoOpenedAccount @"opened_account"

@class LJAccount;

typedef enum {
	FriendsPage = 1,
	Post = 2,
	NewPost = 3
} OpenedScreenType;

@interface AccountManager : NSObject {
	NSMutableArray *accounts;
	NSMutableDictionary *accountsDict;
	
	NSMutableDictionary *stateInfo;
}

+ (AccountManager *)sharedManager;

// kontu pārvaldīšana
- (void)loadAccounts;
- (void)storeAccounts;
- (NSMutableArray *)accounts;
- (LJAccount *)accountForKey:(NSString *)key;
#ifdef LITEVERSION
- (LJAccount *)account;
- (void)storeAccount:(LJAccount *)account;
#endif

// stāvokļa pārvaldīšana
- (void)loadScreenState;
- (void)storeScreenState;
- (BOOL)isScreenRestoreEnabled;
- (NSMutableDictionary *)stateInfo;
// nolasīšana
- (NSString *)openedAccount;
- (OpenedScreenType)openedScreenTypeForAccount:(NSString *)account;
- (NSString *)firstVisiblePostForAccount:(NSString *)account;
- (NSUInteger)scrollPositionForFirstVisiblePostForAccount:(NSString *)account;
- (NSString *)openedPostForAccount:(NSString *)account;
- (NSUInteger)scrollPositionForOpenedPostForAccount:(NSString *)account;
// uzstādīšana
- (void)setOpenedAccount:(NSString *)account;

@end
