//
//  FriendListController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.20.
//  Copyright 2009 A25. All rights reserved.
//

#import "LJFriendsPageController.h"

#import "Macros.h"

#import "JournalerAppDelegate.h"
#import "LiveJournal.h"
#import "Model.h"
#import "PostPreviewCell.h"
#import "ErrorHandler.h"
#import "AccountManager.h"
#import "LJManager.h"

#define kServerReadError -1

@implementation LJFriendsPageController

@synthesize mainView = tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	friendsPageView = tableView;
		
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managerDidLoadPosts:) name:LJManagerDidLoadPostsNotification object:ljManager];
}

- (void)viewDidUnload {
	friendsPageView = nil;
	
	[displayedPosts release];
	displayedPosts = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	if (previousAccount == self.account) {
		[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:animated];
	} else {
		previousAccount = self.account;
		
		tableView.alpha = 0.0f;
		tableView.userInteractionEnabled = NO;
		[self showActivityIndicator];
		
		[ljManager loadPostsForAccount:self.account];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	needOpenPost = OpenedScreenPost == self.accountStateInfo.openedScreen;
	[self saveScrollPosition];
	[super viewDidAppear:animated];
}

- (void)deviceOrientationChanged {
	for (UITableViewCell *cell in [tableView visibleCells]) {
		[[cell.contentView.subviews lastObject] setNeedsDisplay];
	}
}

#pragma mark Darbs ar rakstiem

- (void)managerDidLoadPosts:(NSNotification *)notification {
	if (self.account == [[notification userInfo] objectForKey:@"account"]) {
		if (![ljManager loadingPostsForAccount:self.account]) {
			[self hideActivityIndicator];
		}
		if ([[ljManager loadedPostsForAccount:self.account] count]) {
			[self reloadTable];
		}
	}
}

- (void)managerDidFail:(NSNotification *)notification {
	if (self.account == [[notification userInfo] objectForKey:@"account"]) {
		[self hideActivityIndicator];
		[errorHandler showErrorMessageForAccount:self.account 
											text:[errorHandler decodeError:[[[notification userInfo] objectForKey:@"error"] code]]
										   title:NSLocalizedString(@"Sync error", nil)];
	}
} 

- (void)refresh {
	[self showActivityIndicator];
	[ljManager refreshPostsForAccount:self.account];
}

- (void)reloadTable {
	if (tableView.dragging) {
		needReloadTable = YES;
	} else {
		[displayedPosts release];
		displayedPosts = [[friendsPageFilter filterPosts:[ljManager loadedPostsForAccount:self.account] account:self.account] retain];

		[tableView reloadData];
		
		// pārliecinamies, ka tabula ir redzama
		tableView.alpha = 1.0f;
		tableView.userInteractionEnabled = YES;
		
		if ([displayedPosts count]) {
			NSString *firstVisiblePost = self.accountStateInfo.firstVisiblePost;
			if (firstVisiblePost) {
				// ja pirmais redzamais raksts ir zināms, tad cenšamies atjaunot iepriekšējo tabulas stāvokli
				NSUInteger row = 0;
				for (Post *post in displayedPosts) {
					if ([firstVisiblePost isEqualToString:post.uniqueKey]) {
						NSUInteger scrollPosition = row * 88 + self.accountStateInfo.firstVisiblePostScrollPosition;
						NSUInteger lowerAllowedPosition = tableView.contentSize.height - tableView.bounds.size.height;
						[tableView setContentOffset:CGPointMake(0, scrollPosition > lowerAllowedPosition ? lowerAllowedPosition : scrollPosition)];
						return;
					}
					row++;
				}

				[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[displayedPosts count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
			} else {
				// ja pirmais redzamais raksts nav zināms, tad tabulu tinam uz augšu
				[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
			}
		}
	}
}

- (void)filterFriendsPage {
	[self resetScrollPostion];
	[self reloadTable];
}

- (void)restoreState {
	if (self.accountStateInfo.openedScreen == OpenedScreenPost) {
		[self view];
		
		[ljManager forceLoadPostsForAccount:self.account];
		friendsPageFilter = self.accountStateInfo.friendsPageFilter;
		[self reloadTable];
		
		openedPostIndex = self.accountStateInfo.openedPostIndex;
		[tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:openedPostIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
		[self.navigationController pushViewController:postViewController animated:NO];
	}
}

#pragma mark Table view methods

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [displayedPosts count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *MyIdentifier = @"PostPreview";
	
	PostPreviewCell *cell = (PostPreviewCell *)[aTableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[PostPreviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}

	Post *post = [displayedPosts objectAtIndex:indexPath.row];
	[cell setPost:post];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	openedPostIndex = indexPath.row;
	[self.navigationController pushViewController:postViewController animated:YES];
}

- (void)resetScrollPostion {
	self.accountStateInfo.firstVisiblePost = nil;
	self.accountStateInfo.firstVisiblePostScrollPosition = 0;
	self.accountStateInfo.lastVisiblePostIndex = 0;
}

- (void)saveScrollPosition {
	NSArray *indexPaths = [tableView indexPathsForVisibleRows];
	if (indexPaths && [indexPaths count] > 0) {
		NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
		NSUInteger row = indexPath.row;
		self.accountStateInfo.firstVisiblePost = [(Post *)[displayedPosts objectAtIndex:row] uniqueKey];
		self.accountStateInfo.firstVisiblePostScrollPosition = ((NSUInteger)tableView.contentOffset.y) % 88;
		self.accountStateInfo.lastVisiblePostIndex = [(NSIndexPath *)[indexPaths objectAtIndex:0] row] + 5;
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self saveScrollPosition];
	
	if (needReloadTable) {
		needReloadTable = NO;
		[self reloadTable];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (!decelerate) {
		[self scrollViewDidEndDecelerating:scrollView];
	}
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
	[self scrollViewDidEndDecelerating:scrollView];
}

#pragma mark -

- (NSInteger)postCount {
	return [displayedPosts count];
}
- (NSInteger)openedPostIndex {
	return openedPostIndex;
}

- (Post *)openedPost {
	return [displayedPosts objectAtIndex:openedPostIndex];
}

- (BOOL)hasPreviousPost {
	return openedPostIndex > 0;
}

- (BOOL)hasNextPost {
	return openedPostIndex < ([displayedPosts count] - 1);
}

- (void)openPreviousPost {
	if ([self hasPreviousPost]) {
		openedPostIndex--;
		[self selectOpenedPost];
	}
}

- (void)openNextPost {
	if ([self hasNextPost]) {
		openedPostIndex++;
		[self selectOpenedPost];
	}
}

- (void)selectOpenedPost {
	[tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:openedPostIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

@end

