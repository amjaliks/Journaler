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
#import "LiveJournal.h"

#define kReadLimitPerAttempt 10

@class PostSummaryCell, Post, LJManager;

@interface LJFriendsPageController : FriendsPageController <UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UITableView *tableView;
	IBOutlet PostViewController *postViewController;
	
	// ielasīti raksti
	NSArray *displayedPosts;

	// atvērtā raksta indekss
	NSInteger openedPostIndex;
	
	BOOL needOpenPost;
	BOOL needReloadTable;
}

#pragma mark Metodes

@property (readonly) Post *openedPost;

// raksti
- (void)managerDidLoadPosts:(NSNotification *)notification;

- (void)reloadTable;

- (void)deviceOrientationChanged;
- (void)resetScrollPostion;
- (void)saveScrollPosition;

- (NSInteger)postCount;
- (NSInteger)openedPostIndex;
- (BOOL)hasPreviousPost;
- (BOOL)hasNextPost;
- (void)openPreviousPost;
- (void)openNextPost;
- (void)selectOpenedPost;

@end
