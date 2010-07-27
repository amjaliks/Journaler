//
//  LJManager.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.26.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

#define LJManagerDidLoadPostsNotification @"LJManagerDidLoadPostsNotification"

@class LJAccount;

@interface LJManager : NSObject {
	NSMutableSet *loadingPosts;
	NSMutableDictionary *loadedPosts;
	
	Model *model;
	NSNotificationCenter *notificationCenter;
}

+ (LJManager *)manager;

#pragma mark Raksti
#pragma mark - komandas
- (void)loadPostsForAccount:(LJAccount *)account;
- (void)refreshPostsForAccount:(LJAccount *)account;
#pragma mark - dati
- (BOOL)loadingPostsForAccount:(LJAccount *)account;
- (NSArray *)loadedPostsForAccount:(LJAccount *)account;
#pragma mark - rutīnas metodes
- (void)backgroundLoadPostsForAccount:(LJAccount *)account;

#pragma mark Sesijas
- (void)createSessionForPost:(LJAccount *)account;

#pragma mark Rutīnas metodes
- (void)postNotification:(NSString *)name account:(LJAccount *)account;

@end
