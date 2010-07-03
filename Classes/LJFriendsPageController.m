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
	}
	
	// ielādējam draugu lapu no servera
	if ([self loadFriendsPageFromServer:NO]) {
		// ja ielāde bija veiksmīga, tad pārlādējam tabulu
		[self performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:YES];
	}
	
	// paslēpjam stāvokļa joslu
	[self performSelectorOnMainThread:@selector(hideStatusLine) withObject:nil waitUntilDone:YES];
	
	[pool release];
}

- (BOOL)loadFriendsPageFromServer:(BOOL)allPosts {
	NSError *err;
	
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

- (void)firstSyncReadServer {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (DEFAULT_BOOL(@"refresh_on_start")) {
		@try {
			// atjaunojam pēdējos rakstus
			[self loadLastPostsFromServer];
			if ([loadedPosts count]) {
				Post *topPost = [loadedPosts objectAtIndex:0];
				NSUInteger count = [self loadPostsFromServerAfter:nil skip:0 limit:100]; 
				if (count < 10) {
					[self loadPostsFromServerAfter:nil skip:count limit:10 - count]; 
				}
			} else {
				[self loadPostsFromServerAfter:nil skip:0 limit:10]; 
			}
			
			[self preprocessPosts];
			[self reloadTable];
		}
		@catch (NSException * e) {
			showErrorMessage([e name], [e reason]);
		}
	}
	
	// pārliecinamies, ka tabula ir redzama
	[tableView setAlpha:1.0];
	
	// paslēpjam stāvokļa joslu
	[self hideStatusLine];
	
	[pool release];
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
			[self loadLastPostsFromServer];
			
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

- (void) loadMorePosts {
	@synchronized (self) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		@try {
			// mērķis, cik daudz jābūt ierakstu pēc ielādes
			NSUInteger goal = [loadedPosts count] + 10;
			if (goal > 100) {
				goal = 100;
			}
			
			// vispirms mēģinam ielasīt rakstus no keša
			[self loadPostsFromCacheFromOffset:[loadedPosts count] limit:kReadLimitPerAttempt];
			
			if ([loadedPosts count] < goal) {
				// ja ielādēto rakstu skaits ir mazāks par cerēto,
				// tad cenšiemies ielādēt no servera
				
				// bet vispirms pārbaudam, vai vecākais raksts nav vecāks par 2 nedēļām
				Post *oldestPost = [loadedPosts lastObject];
				if ([oldestPost.dateTime timeIntervalSinceNow] <  -3600 * 24 * 14) {
					// ja ir vecāks par 2 nedēļām, tad atzīmējam, ka vairāk ielādēt nevar
					canLoadMore = NO;
				} else {
					NSUInteger skip = [loadedPosts count];
					while ([loadedPosts count] < goal) {
						// atkārtojam tik ilgi, līdz ir vajadzīgais ierakstu skaits
						NSUInteger items = goal - [loadedPosts count];
						if (items > [self loadPostsFromServerAfter:nil skip:skip limit:items]) {
							// ja ielādējām mazāk nekā cerām, vairāk ielādēt arī nevar
							canLoadMore = NO;
							break;
						} else {
							skip += items;
						}
					}
				}
			}
			
			// veicam rakstu priekšapstrādi
			[self preprocessPosts];
			// atjaunojam tabulu
			[self reloadTable];
		}
		@catch (NSException * e) {
			showErrorMessage([e name], [e reason]);
		}
		
		// parādam stāvokļa joslu
		[self hideStatusLine];

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

- (NSUInteger) loadPostsFromServerAfter:(NSDate *)lastSync skip:(NSUInteger)skip limit:(NSUInteger)limit {
//	LJGetChallenge *challenge = [LJGetChallenge requestWithServer:account.server];
//	if ([challenge doRequest]) {
//		NSString *c = [challenge.challenge retain];
//		LJGetFriendsPage *friendPage = [LJGetFriendsPage requestWithServer:account.server user:account.user password:account.password challenge:c];
//		if (lastSync) {
//			friendPage.lastSync = lastSync;
//		};
//		friendPage.itemShow = [NSNumber numberWithInt:limit];
//		friendPage.skip = [NSNumber numberWithInt:skip];
//		
//		if ([friendPage doRequest]) {
//			[self addNewOrUpdateWithPosts:friendPage.entries];
//			return [friendPage.entries count];
//		} else {
//			[NSException raise:@"Sync error" format:decodeError(friendPage.error)];
//		}
//	} else {
//		[NSException raise:@"Sync error" format:decodeError(challenge.error)];
//	}
	return 0;
}

- (void) loadLastPostsFromServer {
	if ([loadedPosts count]) {
		Post *topPost = [loadedPosts objectAtIndex:0];
		NSUInteger count = [self loadPostsFromServerAfter:topPost.dateTime skip:0 limit:100]; 
		if (count < 10) {
			[self loadPostsFromServerAfter:nil skip:count limit:10 - count]; 
		}
	} else {
		[self loadPostsFromServerAfter:nil skip:0 limit:10]; 
	}
}

- (void) addNewOrUpdateWithPosts:(NSArray *)events {
//	@synchronized(loadedPosts) {
//		Model *model = ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate]).model;
//		for (LJEvent *event in events) {
//			Post *post = [model findPostByAccount:account.title journal:event.journalName dItemId:event.ditemid];
//			if (!post) {
//				post = [model createPost];
//				post.account = account.title;
//				post.journal = event.journalName;
//				post.journalType = event.journalType;
//				post.ditemid = event.ditemid;
//				post.poster = event.posterName;
//				[loadedPosts addObject:post];
//			}
//			post.dateTime = event.datetime;
//			post.subject = event.subject;
//			post.text = event.event;
//			post.replyCount = [NSNumber numberWithInt:event.replyCount];
//			post.userPicURL = event.userPicUrl;
//			post.security = event.security;
//			post.updated = YES;
//			post.rendered = NO;
//			[post clearPreproceedStrings];
//			
//			NSSortDescriptor *dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:NO];
//			[loadedPosts sortUsingDescriptors:[NSArray arrayWithObjects:dateSortDescriptor, nil]];
//			[dateSortDescriptor release];
//			
//			while ([loadedPosts count] > 100) {
//				Post *last = [loadedPosts lastObject];
//				[loadedPosts removeLastObject];
//				[postsPendingRemoval addObject:last];
//			}
//			
//			[model saveAll];
//		}
//	}
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
		
		if (!post.userPic && post.userPicURL && [post.userPicURL length]) {
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

// atjauno stāvokļa rindas tekstu
- (void) updateStatusLineText:(NSString *)text {
	statusLineLabel.text = text;
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
	
//#ifdef LITEVERSION
//	// ar reklāmām saistītie resursi
//	[adMobView release];
//#endif
	
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
	
//#ifdef LITEVERSION
//	[self refreshAdMobView];
//#endif
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (!decelerate) {
		[self scrollViewDidEndDecelerating:scrollView];
	}
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
	[self scrollViewDidEndDecelerating:scrollView];
}

//#ifdef LITEVERSION
//- (NSString *)keywords {
//	if (selectedPostSubject) {
//		// ja ir "iegaumēts" pēdējā lasītā raksta virsraksts, tad izmantojam to
//		return selectedPostSubject;
//	};
//	
//	for (NSIndexPath *indexPath in [tableView indexPathsForVisibleRows]) {
//		Post *post = [displayedPosts objectAtIndex:indexPath.row];
//		if (post.subject) {
//			// tad mēģinam atrast virsrakstu kādam no redzamajiem rakstiem
//			return post.subjectPreview;
//		}
//	}
//	
//	for (Post *post in displayedPosts) {
//		if (post.subject) {
//			// tad mēģinam atrast vismaz vienu virsrakstu
//			return post.subjectPreview;
//		}
//	}
//	
//	// ja neko neizdevās atrast, izmantojam iebūvētos atslēgas vārdus
//	return [super keywords]; 
//}
//
//- (void)refreshAdMobView {
//	[super refreshAdMobView];
//	selectedPostSubject = nil;
//}
//
//#endif

@end

