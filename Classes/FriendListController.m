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
#import "PostSummaryCell.h"
#import "AccountEditorController.h"

#ifdef LITEVERSION
// Lite versijā ir reklāma
#import "AdMobView.h"
#endif


@implementation FriendListController

// tabula
@synthesize tableView;
@synthesize templateCell;
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
		
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// stāvokļa josla
	statusLineView.frame = CGRectMake(0, self.view.frame.size.height - 24, 320, 24);
	
#ifdef LITEVERSION
	adMobView = [AdMobView requestAdWithDelegate:self];
	[adMobView retain];
#endif
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

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
		[self performSelectorInBackground:@selector(reloadTable) withObject:nil];

		// ielādējam rakstus no servera
		if ([loadedPosts count]) {
			Post *topPost = [loadedPosts objectAtIndex:0];
			NSUInteger count = [self loadPostsFromServerAfter:topPost.dateTime skip:0 limit:100]; 
			if (count < 10) {
				[self loadPostsFromServerAfter:nil skip:count limit:10 - count]; 
			}
		} else {
			[self loadPostsFromServerAfter:nil skip:0 limit:10]; 
		}

		// veicam rakstu priekšapstrādi
		[self performSelectorInBackground:@selector(preprocessPosts) withObject:nil];
		// atjaunojam tabulu
		[self performSelectorInBackground:@selector(reloadTable) withObject:nil];
		
		// paslēpjam stāvokļa joslu
		[self performSelectorInBackground:@selector(hideStatusLine) withObject:nil];
		
		[pool release];
	}
}

- (void) loadPostsFromCacheFromOffset:(NSUInteger)offset {
	// ielasam rakstus no keša
	Model *model = ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate]).model;
	NSArray *posts = [model findPostsByAccount:account.title limit:10 offset:offset];
	
	// ieliekam no keša ielasītos rakstu kopējās masīvā
	for (Post *post in posts) {
		if (![loadedPosts containsObject:post]) {
			[loadedPosts addObject:post];
		}
	}
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
	for (Post *post in loadedPosts) {
		post.textPreview;
		post.textView;
	}
}

#pragma mark Stāvokļa josla

// parāda stāvokļa joslu
- (void) showStatusLine {
	//tableView.frame = frameForTableViewWithStatusLine;
	[self.view addSubview:statusLineView];
}

// paslēpj stāvokļa joslu
- (void) hideStatusLine {
	//tableView.frame = frameForTableViewWithOutStatusLine;
	[statusLineView removeFromSuperview];
}

// atjauno stāvokļa rindas tekstu
- (void) updateStatusLineText:(NSString *)text {
	statusLineLabel.text = text;
}

#pragma mark Table view methods

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [loadedPosts count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *MyIdentifier = @"PostSummary";
	
	PostSummaryCell *cell = (PostSummaryCell *)[aTableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"PostSummaryView" owner:self options:nil];
		cell = templateCell;
		cell.tableView = aTableView;
		self.templateCell = nil;
	}
	
	Post *post = [loadedPosts objectAtIndex:indexPath.row];
	cell.post = post;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
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
	
#ifdef LITEVERSION
	// ar reklāmām saistītie resursi
	[adMobView release];
#endif
	
	[super dealloc];
}


@end

