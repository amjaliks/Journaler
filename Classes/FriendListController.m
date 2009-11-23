//
//  FriendListController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.20.
//  Copyright 2009 A25. All rights reserved.
//

#import "FriendListController.h"

#import "JournalerAppDelegate.h"
#import "LiveJournal.h"
#import "Model.h"
#import "PostPreviewCell.h"
#import "PostViewController.h"
#import "AccountEditorController.h"

#ifdef LITEVERSION
// Lite versijā ir reklāma
#import "AdMobView.h"
#endif

NSString* md5(NSString *str);

@implementation FriendListController

// tabula
@synthesize tableView;
@synthesize templateCell;
@synthesize loadMoreCell;
// stāvokļa josla
@synthesize statusLineView;
@synthesize statusLineLabel;

- (id)initWithAccount:(LJAccount *)aAccount {
    if (self = [super initWithNibName:@"FriendListController" bundle:nil]) {
		account = aAccount;
		
		// cilnes bildīte
		UIImage *image = [UIImage imageNamed:@"friends.png"];
		UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Friends" image:image tag:0];
		super.tabBarItem = tabBarItem;
		[tabBarItem release];
		
		// rakstu masīva inicializācija
		loadedPosts = [[NSMutableArray alloc] init];
		
		// kešs
		cachedPostViewControllers = [[NSMutableDictionary alloc] init];
		
		canLoadMore = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// izņemam tabulu, lai lietājs neredz to tukšu
	[tableView setAlpha:0];
	// stāvokļa josla
	statusLineView.frame = CGRectMake(0, self.view.frame.size.height - 24, 320, 24);
	
	// pieliekam pogas
	refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
	self.parentViewController.navigationItem.rightBarButtonItem = refreshButtonItem;
	
#ifdef LITEVERSION
	adMobView = [AdMobView requestAdWithDelegate:self];
	[adMobView retain];
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	if (!account.synchronized) {
		account.synchronized = YES;
		[self performSelectorInBackground:@selector(firstSync) withObject:nil];
	}
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
}

#pragma mark Darbs ar rakstiem

// pirmā sinhronizācija pēc palaišanas
- (void) firstSync {
	@synchronized(self) {		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		// parādam stāvokļa joslu
		[self performSelectorInBackground:@selector(showStatusLine) withObject:nil];
		
		// lasam no keša pirmos 10 ierakstus
		[self loadPostsFromCacheFromOffset:0];
		
		// atjaunojam tabulu
		if ([loadedPosts count]) {
			[tableView setAlpha:1.0];
			[self performSelectorInBackground:@selector(reloadTable) withObject:nil];
		}

		if (DEFAULT(@"refresh_on_start")) {
			// atjaunojam pēdējos rakstus
			[self loadLastPostsFromServer];
			if ([loadedPosts count]) {
				Post *topPost = [loadedPosts objectAtIndex:0];
				NSUInteger count = [self loadPostsFromServerAfter:topPost.dateTime skip:0 limit:100]; 
				if (count < 10) {
					[self loadPostsFromServerAfter:nil skip:count limit:10 - count]; 
				}
			} else {
				[self loadPostsFromServerAfter:nil skip:0 limit:10]; 
			}

			// atjaunojam tabulu
			[self performSelectorInBackground:@selector(reloadTable) withObject:nil];
		}
		
		// veicam rakstu priekšapstrādi
		[self performSelectorInBackground:@selector(preprocessPosts) withObject:nil];
		// pārliecinamies, ka tabula ir redzama
		[tableView setAlpha:1.0];
		
		// paslēpjam stāvokļa joslu
		[self hideStatusLine];
		
		[pool release];
	}
}

- (void) refresh {
	refreshButtonItem.enabled = NO;
	[self performSelectorInBackground:@selector(refreshPosts) withObject:nil];
}

- (void) refreshPosts {
	@synchronized (self) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

		// parādam stāvokļa joslu
		[self performSelectorInBackground:@selector(showStatusLine) withObject:nil];
		//[self showStatusLine];

		// atjaunojam rakstus
		[self loadLastPostsFromServer];
		
		[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
		// veicam rakstu priekšapstrādi
		[self performSelectorInBackground:@selector(preprocessPosts) withObject:nil];
		// atjaunojam tabulu
		[self performSelectorInBackground:@selector(reloadTable) withObject:nil];

		// parādam stāvokļa joslu
		[self hideStatusLine];

		refreshButtonItem.enabled = YES;
		[pool release];
	}
}

- (void) loadMorePosts {
	@synchronized (self) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		// parādam stāvokļa joslu
		[self performSelectorInBackground:@selector(showStatusLine) withObject:nil];
		

		// mērķis, cik daudz jābūt ierakstu pēc ielādes
		NSUInteger goal = [loadedPosts count] + 10;
		if (goal > 100) {
			goal = 100;
		}
		
		// vispirms mēģinam ielasīt rakstus no keša
		[self loadPostsFromCacheFromOffset:[loadedPosts count]];
		
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
		[self performSelectorInBackground:@selector(preprocessPosts) withObject:nil];
		// atjaunojam tabulu
		[self performSelectorInBackground:@selector(reloadTable) withObject:nil];
		
		// parādam stāvokļa joslu
		[self hideStatusLine];
		
		[pool release];
	}
}

- (NSUInteger) loadPostsFromCacheFromOffset:(NSUInteger)offset {
	// ielasam rakstus no keša
	Model *model = ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate]).model;
	NSArray *posts = [model findPostsByAccount:account.title limit:10 offset:offset];
	
	// ieliekam no keša ielasītos rakstu kopējās masīvā
	for (Post *post in posts) {
		if (![loadedPosts containsObject:post]) {
			[loadedPosts addObject:post];
		}
	}
	
	return [posts count];
}

- (NSUInteger) loadPostsFromServerAfter:(NSDate *)lastSync skip:(NSUInteger)skip limit:(NSUInteger)limit {
	LJGetChallenge *challenge = [LJGetChallenge requestWithServer:account.server];
	if ([challenge doRequest]) {
		NSString *c = [challenge.challenge retain];
		LJGetFriendsPage *friendPage = [LJGetFriendsPage requestWithServer:account.server user:account.user password:account.password challenge:c];
		if (lastSync) {
			friendPage.lastSync = lastSync;
		};
		friendPage.itemShow = [NSNumber numberWithInt:limit];
		friendPage.skip = [NSNumber numberWithInt:skip];
		
		if ([friendPage doRequest]) {
			[self addNewOrUpdateWithPosts:friendPage.entries];
			return [friendPage.entries count];
		} else {
			showErrorMessage(@"Sync error", friendPage.error);
		}
	} else {
		showErrorMessage(@"Sync error", challenge.error);
	}
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
	@synchronized(loadedPosts) {
		Model *model = ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate]).model;
		for (LJEvent *event in events) {
			Post *post = [model findPostByAccount:account.title journal:event.journalName dItemId:event.ditemid];
			if (!post) {
				post = [model createPost];
				post.account = account.title;
				post.journal = event.journalName;
				post.journalType = event.journalType;
				post.ditemid = event.ditemid;
				post.poster = event.posterName;
				[loadedPosts addObject:post];
			}
			post.dateTime = event.datetime;
			post.subject = event.subject;
			post.text = event.event;
			post.replyCount = [NSNumber numberWithInt:event.replyCount];
			post.userPicURL = event.userPicUrl;
			post.security = event.security;
			post.updated = YES;
			post.rendered = NO;
			[post clearPreproceedStrings];
			
			NSSortDescriptor *dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:NO];
			[loadedPosts sortUsingDescriptors:[NSArray arrayWithObjects:dateSortDescriptor, nil]];
			[dateSortDescriptor release];
			
			while ([loadedPosts count] > 100) {
				Post *last = [loadedPosts lastObject];
				[model deletePost:last];
				[loadedPosts removeLastObject];
			}
			
			[model saveAll];
		}
	}
}

- (void) reloadTable {
	@synchronized(loadedPosts) {
		[tableView reloadData];
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

#pragma mark Stāvokļa josla

// parāda stāvokļa joslu
- (void) showStatusLine {
	@synchronized (statusLineView) {
		if (!statusLineShowed) {
			[self.view addSubview:statusLineView];
		}
		statusLineShowed++;
	}
}

// paslēpj stāvokļa joslu
- (void) hideStatusLine {
	@synchronized (statusLineView) {
		statusLineShowed--;
		if (!statusLineShowed) {
			[statusLineView removeFromSuperview];
		}
	}
}

// atjauno stāvokļa rindas tekstu
- (void) updateStatusLineText:(NSString *)text {
	statusLineLabel.text = text;
}

#pragma mark Table view methods

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSUInteger count = [loadedPosts count];
	if (count) {
		return count < 100 && canLoadMore ? count + 1 : count;
	} else {
		return 0;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < [loadedPosts count]) {
		static NSString *MyIdentifier = @"PostPreview";
		
		PostPreviewCell *cell = (PostPreviewCell *)[aTableView dequeueReusableCellWithIdentifier:MyIdentifier];
		if (cell == nil) {
			cell = [[[PostPreviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
		}

		Post *post = [loadedPosts objectAtIndex:indexPath.row];
		[cell setPost:post];

		return cell;
	} else {
		loadMoreCell.textLabel.text = @"Load more...";
		return loadMoreCell;
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	if (indexPath.row == [loadedPosts count]) {
		loadMoreCell.textLabel.text = @"Loading...";
		[self performSelectorInBackground:@selector(loadMorePosts) withObject:nil];
	} else {
		Post *post = [loadedPosts objectAtIndex:indexPath.row];
		PostViewController *postViewController = [[cachedPostViewControllers objectForKey:post.uniqueKey] retain];
		if (!postViewController) {
			postViewController = [[PostViewController alloc] initWithPost:[loadedPosts objectAtIndex:indexPath.row] account:account];
			[cachedPostViewControllers setObject:postViewController forKey:post.uniqueKey];
		}
		[self.navigationController pushViewController:postViewController animated:YES];
		[postViewController release];
	}
}

#pragma mark Reklāma

#ifdef LITEVERSION

- (NSString *)publisherId {
	return @"a14ae77c080ab49"; // this should be prefilled; if not, get it from www.admob.com
}

- (UIColor *)adBackgroundColor {
	return [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
}

- (UIColor *)primaryTextColor {
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
}

- (UIColor *)secondaryTextColor {
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
}

- (BOOL)mayAskForLocation {
	return NO;
}

- (void)didReceiveAd:(AdMobView *)adView {
	CGRect frame = tableView.frame;
	frame.origin.y += 48;
	frame.size.height -= 48;
	tableView.frame = frame;
	
	[self.view addSubview:adView];
}

- (void)didFailToReceiveAd:(AdMobView *)adView {
	[adMobView release];
}

// To receive test ads rather than real ads...
#ifdef DEBUG
- (BOOL)useTestAd {
	return YES;
}

- (NSString *)testAdAction {
	return @"url"; // see AdMobDelegateProtocol.h for a listing of valid values here
}
#endif

#endif

- (void)dealloc {
	[loadedPosts release];
	[cachedPostViewControllers release];
	
#ifdef LITEVERSION
	// ar reklāmām saistītie resursi
	[adMobView release];
#endif
	
	[super dealloc];
}


@end

