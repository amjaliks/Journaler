//
//  LJManager.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.26.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

#define LJManagerStepCompletedNotification @"LJManagerStepCompletedNotification"

@class LJAccount;

@interface LJManager : NSObject {
	NSMutableSet *loadingPosts;
	NSMutableDictionary *loadedPosts;
	
	Model *model;
	NSNotificationCenter *notificationCenter;
}

+ (LJManager *)manager;

- (void)loadPostsForAccount:(LJAccount *)account;
- (void)refreshPostsForAccount:(LJAccount *)account;

- (void)backgroundLoadPostsForAccount:(LJAccount *)account;

- (BOOL)loadingPostsForAccount:(LJAccount *)account;
- (NSArray *)loadedPostsForAccount:(LJAccount *)account;

@end
