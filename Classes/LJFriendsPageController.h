//
//  FriendListController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.20.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsPageController.h"

@class LJAccount, PostSummaryCell;

@interface LJFriendsPageController : FriendsPageController <UITableViewDataSource, UITableViewDelegate> {
	// ielasīti raksti
	NSMutableArray *loadedPosts;
	
	// tabula
	UITableView *tableView;
	UITableViewCell *loadMoreCell;
	BOOL canLoadMore;
	BOOL loading;

	// kešs ar rakstu skatījumiem
	NSMutableDictionary *cachedPostViewControllers;
}

#pragma mark Metodes

// raksti
- (void) firstSync;
- (void) firstSyncReadCache;
- (void) firstSyncReadServer;
- (void) refreshPosts;
- (void) loadMorePosts;
- (NSUInteger) loadPostsFromCacheFromOffset:(NSUInteger)offset;
- (NSUInteger) loadPostsFromServerAfter:(NSDate *)lastSync skip:(NSUInteger)skip limit:(NSUInteger)limit;
- (void) loadLastPostsFromServer;
- (void) addNewOrUpdateWithPosts:(NSArray *)events;
- (void) reloadTable;
- (void) preprocessPosts;
- (void) updateStatusLineText:(NSString *)text;

@end
