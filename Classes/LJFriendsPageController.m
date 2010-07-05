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
#import "PostViewController.h"
#import "ErrorHandling.h"
#import "AccountManager.h"

#define kServerReadError -1

@implementation LJFriendsPageController

- (id)initWithAccount:(LJAccount *)aAccount {
    if (self = [super initWithAccount:aAccount]) {
		// rakstu masīva inicializācija
		postsPendingRemoval = [[NSMutableArray alloc] init];
		
		// kešs
		cachedPostViewControllers = [[NSMutableDictionary alloc] init];
		
		canLoadMore = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	tableView.dataSource = self;
	tableView.delegate = self;
	tableView.rowHeight = 88;
	[self.view addSubview:tableView];
	
	friendsPageView = tableView;
		
	// izņemam tabulu, lai lietājs neredz to tukšu
	[tableView setAlpha:0];
	
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;// || UIView;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	needOpenPost = OpenedScreenPost == [[AccountManager sharedManager] stateInfoForAccount:account.title].openedScreen;
	[super viewDidAppear:animated];
	if (!account.synchronized) {
		account.synchronized = YES;
		[self performSelectorInBackground:@selector(firstSync) withObject:nil];
	}
}

- (void) deviceOrientationChanged {
	for (UITableViewCell *cell in [tableView visibleCells]) {
		[[cell.contentView.subviews lastObject] setNeedsDisplay];
	}
}

- (void)showStatusLine {
	loading = YES;
	[super showStatusLine];
	refreshButtonItem.enabled = NO;
}

- (void)hideStatusLine {
	loading = NO;
	[super hideStatusLine];
	refreshButtonItem.enabled = YES;
}

#pragma mark Darbs ar rakstiem

// pirmā sinhronizācija pēc palaišanas
- (void)firstSync {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// parādam stāvokļa joslu
	[self performSelectorOnMainThread:@selector(showStatusLine) withObject:nil waitUntilDone:YES];
	
	// lasam ierakstus no keša
	Model *model = ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate]).model;
	loadedPosts = [[model findPostsByAccount:account.title] mutableCopy];
	
	if (needOpenPost) {
		// ja nepieciešams, tad atveram iepriekš atvērto rakstu
		NSString *postKey = [[AccountManager sharedManager] stateInfoForAccount:account.title].openedPost;
		if (postKey) {
			for (Post *post in loadedPosts) {
				if ([postKey isEqualToString:post.uniqueKey]) {
					[self performSelectorOnMainThread:@selector(openPost:) withObject:post waitUntilDone:YES];
					break;
				}
			}
		}
	}
	
	if ([loadedPosts count]) {
		// ja kešā ir ieraksti, tad tos parādam
		[self performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:YES];
		[self preprocessPosts];
	}
	
	// ielādējam draugu lapu no servera
	if ([self loadFriendsPageFromServer:YES]) {
		// ja ielāde bija veiksmīga, tad pārlādējam tabulu
		[self performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:YES];
		[self preprocessPosts];
	}
	
	// paslēpjam stāvokļa joslu
	[self performSelectorOnMainThread:@selector(hideStatusLine) withObject:nil waitUntilDone:YES];
	
	[pool release];
}

- (BOOL)loadFriendsPageFromServer:(BOOL)allPosts {
	NSError *err = nil;
	
	// ielādējam notikumus no servera
	NSArray *events = [[LJManager defaultManager] friendsPageEventsForAccount:account lastSync:nil error:&err];
	
	if (!err) {
		Model *model = ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate]).model;
		for (LJEvent *event in events) {
			Post *post = [model findPostByAccount:account.title journal:event.journal dItemId:event.ditemid];
			if (!post) {
				post = [model createPost];
				post.account = account.title;
				post.journal = event.journal;
				post.journalType = event.journalType == LJJournalTypeJournal ? @"J" : @"C";
				post.ditemid = event.ditemid;
				post.poster = event.poster;
				[loadedPosts addObject:post];
			}
			post.dateTime = event.datetime;
			post.subject = event.subject;
			post.text = event.event;
			post.replyCount = [NSNumber numberWithInt:event.replyCount];
			post.userPicURL = event.userPicUrl;
			post.security = event.security == LJEventSecurityPublic ? @"public" : @"private";
			post.updated = YES;
			post.rendered = NO;
			[post clearPreproceedStrings];
		}
		
		NSSortDescriptor *dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:NO];
		[loadedPosts sortUsingDescriptors:[NSArray arrayWithObjects:dateSortDescriptor, nil]];
		[dateSortDescriptor release];
		
		while ([loadedPosts count] > 100) {
			Post *last = [loadedPosts lastObject];
			[loadedPosts removeLastObject];
			[postsPendingRemoval addObject:last];
		}
		
		[model saveAll];
		
		return YES;
	} else {
		// ja ir kļūda, tad rādam paziņojumu
		showErrorMessage(@"Sync error", decodeError([err code]));
		return NO;
	}
}

- (void) refresh {
	refreshButtonItem.enabled = NO;
	[self showStatusLine];
	
	[self performSelectorInBackground:@selector(refreshPosts) withObject:nil];
}

- (void) refreshPosts {
	@synchronized (self) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

		BOOL needToScroll = [loadedPosts count];
		
		@try {
			// atjaunojam rakstus
			[self loadFriendsPageFromServer:NO];
			
			if (needToScroll) {
				[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
			}
			// veicam rakstu priekšapstrādi
			[self preprocessPosts];
			// atjaunojam tabulu
			[self reloadTable];
		}
		@catch (NSException * e) {
			showErrorMessage([e name], [e reason]);
		}

		// paslēpjam stāvokļa joslu
		[self hideStatusLine];

		refreshButtonItem.enabled = YES;
		
		[pool release];
	}
}


- (NSUInteger) loadPostsFromCacheFromOffset:(NSUInteger)offset limit:(NSUInteger)limit {
	// ielasam rakstus no keša
	Model *model = ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate]).model;
	NSArray *posts = [model findPostsByAccount:account.title limit:limit offset:offset];
	
	// ieliekam no keša ielasītos rakstu kopējās masīvā
	for (Post *post in posts) {
		if (![loadedPosts containsObject:post]) {
			[loadedPosts addObject:post];
		}
	}
	
	return [posts count];
}

- (void) reloadTable {
	if (tableView.dragging) {
		needReloadTable = YES;
	} else {
		@synchronized(loadedPosts) {
			[displayedPosts release];
			displayedPosts = [loadedPosts copy];

			[tableView reloadData];
			
			// pārliecinamies, ka tabula ir redzama
			[tableView setAlpha:1.0];
			
			NSString *firstVisiblePost = [[AccountManager sharedManager] stateInfoForAccount:account.title].firstVisiblePost;
			if (firstVisiblePost) {
				NSUInteger row = 0;
				for (Post *post in displayedPosts) {
					if ([firstVisiblePost isEqualToString:post.uniqueKey]) {
						NSUInteger scrollPosition = row * 88 + [[AccountManager sharedManager] stateInfoForAccount:account.title].firstVisiblePostScrollPosition;
						NSUInteger lowerAllowedPosition = tableView.contentSize.height - tableView.bounds.size.height;
						[tableView setContentOffset:CGPointMake(0, scrollPosition > lowerAllowedPosition ? lowerAllowedPosition : scrollPosition)];
						return;
					}
					row++;
				}

				// LJ-100
				// iespējams šī pārbaude ļaus izvairīties no kādas kļūdas sekām,
				// diemžēl problēmas celoņi man nav zināmi
				if ([displayedPosts count]) {
					[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[displayedPosts count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
				}
			}
			
			// pēc tabula pārlādes, izdzēšam vecus rakstus no keša
			Model *model = APP_MODEL;
			for (Post *post in postsPendingRemoval) {
				[model deletePost:post];
			}
			[postsPendingRemoval removeAllObjects];
			[model saveAll];
		}
	}
}

- (void) preprocessPosts {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	for (Post *post in loadedPosts) {
		[post textPreview];
		[post textView];
		[post subjectPreview];
		
		if (!post.userPic && [post.userPicURL length]) {
			post.userPic = [APP_USER_PIC_CACHE imageFromCacheForHash:[post userPicURLHash]];
			
			if (post.userPic) {
				if (post.view) {
					[post.view setNeedsDisplay];
				}
			} else {
				[APP_USER_PIC_CACHE performSelectorInBackground:@selector(downloadUserPicForPost:) withObject:post];
			}
		}
	}
	
	[pool release];
}

- (void)openPost:(Post *)post {
	[self openPost:post animated:NO];
}

- (void)openPost:(Post *)post animated:(BOOL)animated {
	PostViewController *postViewController = [[cachedPostViewControllers objectForKey:post.uniqueKey] retain];
	if (!postViewController) {
		postViewController = [[PostViewController alloc] initWithPost:post account:account];
		[cachedPostViewControllers setObject:postViewController forKey:post.uniqueKey];
	}
	[self.navigationController pushViewController:postViewController animated:animated];
	[postViewController release];
}

- (void)openPostByKey:(NSString *)key {
	for (Post *post in loadedPosts) {
		if ([key isEqualToString:post.uniqueKey]) {
			[self openPost:post animated:NO];
			return;
		}
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
	}

	Post *post = [displayedPosts objectAtIndex:indexPath.row];
	[cell setPost:post];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	if (indexPath.row == [displayedPosts count]) {
		if (!loading) {
			[self showStatusLine];
			[self performSelectorInBackground:@selector(loadMorePosts) withObject:nil];
		}
	} else {
		Post *post = [displayedPosts objectAtIndex:indexPath.row];
#ifdef LITEVERSION
		selectedPostSubject = [post subjectPreview];
#endif
		[self openPost:post animated:YES];
	}
}


- (void)dealloc {
	[loadedPosts release];
	[postsPendingRemoval release];
	[cachedPostViewControllers release];
	
	[super dealloc];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	NSArray *indexPaths = [tableView indexPathsForVisibleRows];
	if (indexPaths && [indexPaths count] > 0) {
		NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
		NSUInteger row = indexPath.row;
		[[AccountManager sharedManager] stateInfoForAccount:account.title].firstVisiblePost = [(Post *)[displayedPosts objectAtIndex:row] uniqueKey];
		[[AccountManager sharedManager] stateInfoForAccount:account.title].firstVisiblePostScrollPosition = ((NSUInteger)scrollView.contentOffset.y) % 88;
		[[AccountManager sharedManager] stateInfoForAccount:account.title].lastVisiblePostIndex = [(NSIndexPath *)[indexPaths objectAtIndex:0] row] + 5;
	}
	
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

@end

