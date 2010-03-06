//
//  FriendListController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.20.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsPageController.h"

#define kReadLimitPerAttempt 10

@class LJAccount, PostSummaryCell, Post;

@interface LJFriendsPageController : FriendsPageController <UITableViewDataSource, UITableViewDelegate> {
	// ielasīti raksti
	NSMutableArray *loadedPosts;
	NSArray *displayedPosts;
	// masīvs ar rakstiem, kurus jādzēš
	NSMutableArray *postsPendingRemoval;
	
	// tabula
	UITableView *tableView;
	UITableViewCell *loadMoreCell;
	BOOL canLoadMore;
	BOOL loading;

	// kešs ar rakstu skatījumiem
	NSMutableDictionary *cachedPostViewControllers;
	
	BOOL needOpenPost;
	BOOL needReloadTable;
	
#ifdef LITEVERSION
	NSString *selectedPostSubject;
#endif
}

#pragma mark Metodes

// raksti
- (void) firstSync;
- (void) firstSyncReadCache;
- (void) firstSyncReadServer;
- (void) refreshPosts;
- (void) loadMorePosts;
- (NSUInteger) loadPostsFromCacheFromOffset:(NSUInteger)offset limit:(NSUInteger)limit;
- (NSUInteger) loadPostsFromServerAfter:(NSDate *)lastSync skip:(NSUInteger)skip limit:(NSUInteger)limit;
- (void) loadLastPostsFromServer;
- (void) addNewOrUpdateWithPosts:(NSArray *)events;
- (void) reloadTable;
- (void) preprocessPosts;
- (void) updateStatusLineText:(NSString *)text;
- (void) openPost:(Post *)post animated:(BOOL)animated;
- (void) openPostByKey:(NSString *)key;

- (void) deviceOrientationChanged;

@end
