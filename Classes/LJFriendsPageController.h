//
//  FriendListController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.20.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsPageController.h"
#import "PostViewController.h"

#define kReadLimitPerAttempt 10

@class LJAccount, PostSummaryCell, Post;

@interface LJFriendsPageController : FriendsPageController <UITableViewDataSource, UITableViewDelegate, PostViewControllerDelegate> {
	// ielasīti raksti
	NSMutableArray *loadedPosts;
	NSArray *displayedPosts;
	// masīvs ar rakstiem, kurus jādzēš
	NSMutableArray *postsPendingRemoval;
	
	// tabula
	UITableView *tableView;
	BOOL canLoadMore;
	BOOL loading;

	// kešs ar rakstu skatiem
	NSMutableDictionary *cachedPostViewControllers;
	Post *openedPost;
	
	BOOL needOpenPost;
	BOOL needReloadTable;
}

#pragma mark Metodes

// raksti
- (void)firstSync;
- (BOOL)loadFriendsPageFromServer:(BOOL)allPosts;

- (void)refreshPosts;
- (void)reloadTable;
- (void)preprocessPosts;
- (void)openPost:(Post *)post;
- (void)openPost:(Post *)post animated:(BOOL)animated;
- (void)openPostByKey:(NSString *)key;

- (void)deviceOrientationChanged;
- (void)resetScrollPostion;
- (void)saveScrollPosition;

@end
