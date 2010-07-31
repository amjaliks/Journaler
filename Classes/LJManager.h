//
//  LJManager.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.26.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

#define ljManager [LJManager sharedLJManager]

#define LJManagerDidFailNotification @"LJManagerDidFailNotification"
#define LJManagerDidLoadPostsNotification @"LJManagerDidLoadPostsNotification"
#define LJManagerDidCreateSessionNotification @"LJManagerDidCreateSessionNotification"

@class LJAccount, LJAPIClient;

@interface LJManager : NSObject {
	NSMutableSet *loadingPosts;
	NSMutableDictionary *loadedPosts;
	
	NSMutableSet *generatingSession;
	NSMutableDictionary *sessions;
	
	NSNotificationCenter *notificationCenter;
}

+ (LJManager *)sharedLJManager;

#pragma mark Raksti
#pragma mark - komandas
- (void)loadPostsForAccount:(LJAccount *)account;
- (void)forceLoadPostsForAccount:(LJAccount *)account;
- (void)refreshPostsForAccount:(LJAccount *)account;
- (void)removePostsForAccount:(LJAccount *)account;
#pragma mark - dati
- (BOOL)loadingPostsForAccount:(LJAccount *)account;
- (NSArray *)loadedPostsForAccount:(LJAccount *)account;
#pragma mark - fona procesi
- (void)backgroundLoadPostsForAccount:(LJAccount *)account;
- (void)backgroundRefreshPostsForAccount:(LJAccount *)account;
- (void)mergeCachedPosts:(NSMutableArray *)cachedPosts withNewPosts:(NSArray *)newPosts forAccount:(LJAccount *)account;

#pragma mark Sesijas
- (void)createSessionForAccount:(LJAccount *)account;
- (void)setHTTPCookiesForAccount:(LJAccount *)account;
- (void)backgroundCreateSessionForAccount:(LJAccount *)account;

#pragma mark Rutīnas metodes
- (void)postNotification:(NSString *)name account:(LJAccount *)account;
- (void)postFailNotificationForAccount:(LJAccount *)account error:(NSError *)error;
- (void)didReceiveMemoryWarning;

@end
