//
//  AccountViewController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.04.
//  Copyright 2009 A25. All rights reserved.
//

#import "AccountViewController.h"
#import "LiveJournal.h"
#import "Model.h"
#import "JournalerAppDelegate.h"
#import "UserPicCache.h"
#import "AccountsViewController.h"
#import "PostSummaryCell.h"
#import "AccountEditorController.h"
#import "AdMobView.h"
#import "ALReporter.h"

@implementation AccountViewController

@synthesize tabBar;
@synthesize masterView;

@synthesize ljAccountView;
@synthesize otherAccountView;

@synthesize toolbar;
@synthesize backButton;
@synthesize fixedSpace;
@synthesize forwardButton;
@synthesize flexibleSpace;
@synthesize refreshButton;
@synthesize stopButton;
@synthesize flexibleSpace2;
@synthesize friendsButton;

@synthesize newPostOther;
@synthesize postButton;
@synthesize refreshPostsButton;

@synthesize templateCell;

@synthesize dataSource;

@synthesize previousController;
@synthesize friendsTabController;
@synthesize postEditorTabController;
@synthesize postEditorController;
@synthesize postViewController;
@synthesize accountEditor;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	tabBar.view.frame = CGRectMake(0, 0, 320, 416);
	
#ifndef LITEVERSION
	webViews = [[NSMutableDictionary alloc] init];
#endif
	
#ifdef LITEVERSION
	account = [self loadAccount];
	accountButton = [[UIBarButtonItem alloc] initWithTitle:@"Account" style:UIBarButtonItemStyleBordered target:self action:@selector(editAccount)];
	self.navigationItem.leftBarButtonItem = accountButton;
	
	CGRect frame = otherAccountView.frame;
	frame.origin.y = 48;
	frame.size.height = 324;
	webView = [[UIWebView alloc] initWithFrame:frame];
	[webView setDelegate:self];
	[webView setScalesPageToFit:YES];
	
	[otherAccountView addSubview:webView];
#endif
}

- (void)loadFriendListInWebView:(UIWebView *)lWebView forAccount:(LJAccount *)lAccount {
	NSString *URLFormat;
	if ([@"dreamwidth.org" isEqualToString:lAccount.server]) {
		URLFormat = @"http://%@/~%@/read";
	} else {
		URLFormat = @"http://%@/~%@/friends";
	}
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:URLFormat, lAccount.server, lAccount.user]]];
	[lWebView loadRequest:req];
}

- (void)showMessageRefreshTurnedOffInWebView:(UIWebView *)lWebView {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"RefreshTurnedOff" ofType:@"html"];
	NSURL *URL = [NSURL fileURLWithPath:path];
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	[lWebView loadRequest:request];
}

- (void)initWebView:(UIWebView *)lWebView forAccount:(LJAccount *)lAccount {
	LJGetChallenge *challenge = [LJGetChallenge requestWithServer:lAccount.server];
	if ([challenge doRequest]) {
		
		LJSessionGenerate *session = [LJSessionGenerate requestWithServer:lAccount.server user:lAccount.user password:lAccount.password challenge:challenge.challenge];
		if ([session doRequest]) {
			NSDictionary *cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"ljsession", NSHTTPCookieName, session.ljsession, NSHTTPCookieValue, [NSString stringWithFormat:@".%@", lAccount.server], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
			NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
			[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
			
			cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"ljmastersession", NSHTTPCookieName, session.ljsession, NSHTTPCookieValue, [NSString stringWithFormat:@".%@", lAccount.server], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
			cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
			[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
			
			NSArray *parts = [session.ljsession componentsSeparatedByString:@":"];
			cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"ljloggedin", NSHTTPCookieName, [NSString stringWithFormat:@"%@:%@", [parts objectAtIndex:1], [parts objectAtIndex:2]], NSHTTPCookieValue, [NSString stringWithFormat:@".%@", lAccount.server], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
			cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
			[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
			
			[self loadFriendListInWebView:lWebView forAccount:lAccount];
		} else {
			showErrorMessage(@"Friend page error", session.error);
		}
	} else {
		showErrorMessage(@"Friend page error", challenge.error);
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
		
#ifdef LITEVERSION
	if (!account) {
		[self editAccount];
		return;
	}
#else
	LJAccount *account = [dataSource selectedAccountForAccountViewController:self];
#endif
	
	self.title = account.user;

	[otherAccountView removeFromSuperview];
	[ljAccountView removeFromSuperview];
	[tabBar.view removeFromSuperview];
	
	if ([@"livejournal.com" isEqualToString:[account.server lowercaseString]]) {
		[self.view addSubview:tabBar.view];
		previousController = friendsTabController;
		tabBar.selectedIndex = 0;//[[NSNumber alloc] initWithInteger:0];
		if (previousAccount != account) {
			previousAccount = account;
			Model *model = ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate]).model;
			posts = [[model findPostsByAccount:account.title] mutableCopy];
			if (account.synchronized) {
				[ljAccountView reloadData];
				[ljAccountView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
			} else {
				refreshPostsButton.enabled = NO;
			}
		}
		self.navigationItem.rightBarButtonItem = refreshPostsButton;
	} else {
#ifdef LITEVERSION
		if (!otherAdView) {
			otherAdView = [AdMobView requestAdWithDelegate:self];
			[otherAccountView addSubview:otherAdView];
		}
#endif
		self.navigationItem.rightBarButtonItem = newPostOther;
		
		// nolasam iestatījumus
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		BOOL refreshOnStart = [defaults boolForKey:@"refresh_on_start"];
		
#ifndef LITEVERSION
		if (webView) {
			[webView removeFromSuperview];
		}
		
		webView = [webViews objectForKey:account.title];
		if (!webView) {
			CGRect frame = otherAccountView.frame;
			frame.size.height = 372;
			webView = [[UIWebView alloc] initWithFrame:frame];
			[webView setDelegate:self];
			[webView setScalesPageToFit:YES];
			
			if (refreshOnStart) {
				[self initWebView:webView forAccount:account];
			} else {
				[self showMessageRefreshTurnedOffInWebView:webView];
			}
			
			[webViews setObject:webView forKey:account.title];
		}

		[otherAccountView addSubview:webView];
		backButton.enabled = webView.canGoBack;
		forwardButton.enabled = webView.canGoForward;
#else
		if (refreshOnStart) {
			[self initWebView:webView forAccount:account];
		} else {
			[self showMessageRefreshTurnedOffInWebView:webView];
		}
#endif	
		
		[self.view addSubview:otherAccountView];
	}
}

- (void) addNewOrUpdateWithPosts:(NSArray *)events forAccount:(LJAccount *)acc {
	NSUInteger idx = 0;
	Model *model = ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate]).model;
	for (LJEvent *event in events) {
		Post *post = [model findPostByAccount:acc.title journal:event.journalName dItemId:event.ditemid];
		if (!post) {
			post = [model createPost];
			post.account = acc.title;
			post.journal = event.journalName;
			post.journalType = event.journalType;
			post.ditemid = event.ditemid;
			post.poster = event.posterName;
			[posts insertObject:post atIndex:idx];
			idx++;
		}
		post.dateTime = event.datetime;
		post.subject = event.subject;
		post.text = event.event;
		post.replyCount = [NSNumber numberWithInt:event.replyCount];
		post.userPicURL = event.userPicUrl;
		
		while ([posts count] > 100) {
			Post *last = [posts lastObject];
			[model deletePost:last];
			[posts removeLastObject];
			//[last release];
		}
		
		[model saveAll];
	}
}

- (NSArray *) requestPostsFromServerForAccount:(LJAccount *)acc lastSync:(NSDate *)lastSync skip:(NSUInteger)skip items:(NSUInteger)items {
	LJGetChallenge *challenge = [LJGetChallenge requestWithServer:acc.server];
	if ([challenge doRequest]) {
		NSString *c = [challenge.challenge retain];
		LJGetFriendsPage *friendPage = [LJGetFriendsPage requestWithServer:acc.server user:acc.user password:acc.password challenge:c];
		if (lastSync) {
			friendPage.lastSync = lastSync;
		};
		friendPage.itemShow = [NSNumber numberWithInt:items];
		friendPage.skip = [NSNumber numberWithInt:skip];
		
		if ([friendPage doRequest]) {
			return [friendPage.entries retain];
		} else {
			showErrorMessage(@"Sync error", friendPage.error);
		}
	} else {
		showErrorMessage(@"Sync error", challenge.error);
	}
	return nil;
}

- (void) loadLJPosts {
#ifndef LITEVERSION
	LJAccount *account = [dataSource selectedAccountForAccountViewController:self];
#endif

	if (!account.synchronized) {
#ifdef LITEVERSION
		UIView *view = [[UIView alloc] initWithFrame:[self.view.window frame]];
		[view setBackgroundColor:[UIColor blackColor]];
		[view setOpaque:YES];
		[view setAlpha:0.5];
		[self.view.window addSubview:view];
#endif
	
		// nolasam iestatījumus
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		BOOL refreshOnStart = [defaults boolForKey:@"refresh_on_start"];

		if (refreshOnStart) {
			// ja pie palaišanas vajag vajag atjaunot friendlisti, tad to daram
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			
			NSArray *events;
			if ([posts count]) {
				events = [self requestPostsFromServerForAccount:account lastSync:((Post *)[posts objectAtIndex:0]).dateTime skip:0 items:100];
			} else {
				events = [self requestPostsFromServerForAccount:account lastSync:nil skip:0 items:100];
			}
			
			if (events) {
				[self addNewOrUpdateWithPosts:events forAccount:account];
				[events release];
			}
		}
		
		[ljAccountView reloadData];
		[ljAccountView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
		
		account.synchronized = YES;
		refreshPostsButton.enabled = YES;
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
#ifdef LITEVERSION
		[view removeFromSuperview];
		[view release];
#endif
	};
	[self.masterView addSubview:ljAccountView];
	
	[self scrollViewDidEndDecelerating:ljAccountView];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

#ifndef LITEVERSION
	LJAccount *account = [dataSource selectedAccountForAccountViewController:self];
#endif
	
	if ([@"livejournal.com" isEqualToString:[account.server lowercaseString]]) {
#ifndef LITEVERSION
		[self loadLJPosts];
#else
		[self performSelectorInBackground:@selector(loadLJPosts) withObject:nil];
#endif
	};
}

- (IBAction) refreshPosts:(id) sender {
	refreshPostsButton.enabled = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
#ifndef LITEVERSION
	LJAccount *account = [dataSource selectedAccountForAccountViewController:self];
#endif	

	NSUInteger loaded = 0;
	if ([posts count]) {
		loaded = -1;
		NSArray *events = [self requestPostsFromServerForAccount:account lastSync:((Post *)[posts objectAtIndex:0]).dateTime skip:0 items:100];
		if (events) {
			[self addNewOrUpdateWithPosts:events forAccount:account];
			loaded = [events count];
			[events release];
		}
	};
	
	if (loaded >= 0 && loaded < 10) {
		NSArray *events = [self requestPostsFromServerForAccount:account lastSync:nil skip:loaded items:10 - loaded];
		if (events) {
			[self addNewOrUpdateWithPosts:events forAccount:account];
			[events release];
		}
	};
	
	[ljAccountView reloadData];
	[ljAccountView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	refreshPostsButton.enabled = YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

//- (void)viewDidUnload {
//	// Release any retained subviews of the main view.
//	// e.g. self.myOutlet = nil;
//}


- (void)dealloc {
    [super dealloc];
#ifndef LITEVERSION
	[webViews release];
#endif
}

- (IBAction) goToUpdate {
	[self presentModalViewController:postEditorController animated:YES];
}

- (LJAccount *)selectedAccountForPostEditorController:(PostEditorController *)controller {
#ifdef LITEVERSION
	return account;
#else
	return [dataSource selectedAccountForAccountViewController:self];
#endif
}

- (LJAccount *) selectedAccountForPostViewController:(PostViewController *)controller {
#ifdef LITEVERSION
	return account;
#else
	return [dataSource selectedAccountForAccountViewController:self];
#endif
}

- (void)postEditorControllerDidFinish:(PostEditorController *)controller {
	[self dismissModalViewControllerAnimated:YES];
}


- (void)webViewDidStartLoad:(UIWebView *)webView_ {
	backButton.enabled = webView.canGoBack;
	forwardButton.enabled = webView.canGoForward;
	
	[toolbar setItems:[NSArray arrayWithObjects:
					   backButton, fixedSpace, forwardButton, flexibleSpace, stopButton, flexibleSpace2, friendsButton, nil]
			 animated:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView_ {
	backButton.enabled = webView.canGoBack;
	forwardButton.enabled = webView.canGoForward;

	[toolbar setItems:[NSArray arrayWithObjects:
					   backButton, fixedSpace, forwardButton, flexibleSpace, refreshButton, flexibleSpace2, friendsButton, nil]
									   animated:NO];
}

- (BOOL)webView:(UIWebView *)webView_ shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if ([@"initwebview" isEqualToString:[[request URL] scheme]]) {
#ifndef LITEVERSION
		LJAccount *account = [dataSource selectedAccountForAccountViewController:self];
#endif

		[self initWebView:webView forAccount:account];
		return NO;
	} else {
		return YES;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#ifdef LITEVERSION
	NSUInteger count = [posts count];
	count += (count / 10 + 1);
	return count;
#else
	return [posts count];
#endif
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
#ifdef LITEVERSION
	if (indexPath.row % 10 == 0) {
		static NSString *AdIdentifier = @"AdCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AdIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:AdIdentifier] autorelease];
			[cell.contentView addSubview:[AdMobView requestAdWithDelegate:self]];
			lastAdRequest = [[NSDate date] retain];
		} else {
			if ([lastAdRequest timeIntervalSinceNow] < -60.0) {
				[lastAdRequest release];
				lastAdRequest = [[NSDate date] retain];
				AdMobView *adView = (AdMobView *)[cell.contentView.subviews lastObject];
				[adView requestFreshAd];
			}
		}
		return cell;
	} else {
#else
	{
#endif
		static NSString *MyIdentifier = @"PostSummary";
		
		PostSummaryCell *cell = (PostSummaryCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"PostSummaryView" owner:self options:nil];
			cell = templateCell;
			cell.tableView = tableView;
			self.templateCell = nil;
		}
#ifdef LITEVERSION
		NSUInteger index = indexPath.row;
		index -= (index / 10 + 1);
		Post *post = [posts objectAtIndex:index];
#else
		Post *post = [posts objectAtIndex:indexPath.row];
#endif
		cell.post = post;
		
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
#ifdef LITEVERSION
	NSUInteger index = indexPath.row;
	index -= (index / 10 + 1);
	selectedPost = [posts objectAtIndex:index];
#else
	selectedPost = [posts objectAtIndex:indexPath.row];
#endif
	[self.navigationController pushViewController:postViewController animated:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (Post *) selectEventForPostViewController:(PostViewController *)controller {
	return selectedPost;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	if (previousController != viewController) {
		previousController = viewController;
		if (viewController == friendsTabController) {
			self.navigationItem.rightBarButtonItem = refreshPostsButton;
		} else if (viewController == postEditorTabController) {
			self.navigationItem.rightBarButtonItem = postButton;
		}
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	UITableView *tableView = (UITableView *)scrollView;
	NSArray *cells = [tableView visibleCells];
#ifdef LITEVERSION
	for (UITableViewCell *rawCell in cells) {
		if (![rawCell isKindOfClass:[PostSummaryCell class]]) {
			continue;
		}
		PostSummaryCell *cell = (PostSummaryCell *)rawCell;
#else
	for (PostSummaryCell *cell in cells) {
#endif
		if (cell.post.userPicURL && [cell.post.userPicURL length]) {
			UserPicCache *userPicCache = ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate]).userPicCache;
			[cell setUserPic:[[userPicCache imageFromURL:cell.post.userPicURL forTableView:tableView] retain]];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (!decelerate) {
		[self scrollViewDidEndDecelerating:scrollView];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	UserPicCache *userPicCache = ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate]).userPicCache;
	[userPicCache cancelPendingDownloads];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
	[self scrollViewDidEndDecelerating:scrollView];
}

#ifdef LITEVERSION
	
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.row % 10 == 0) {
		return 48.0; // this is the height of the AdMob ad
	}
	return 88.0; // this is the generic cell height
}
	
- (LJAccount *)loadAccount {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];
	path = [path stringByAppendingPathComponent:@"account.bin"];
	LJAccount *acc = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	return [acc retain];
}

- (void) saveAccount {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];
	path = [path stringByAppendingPathComponent:@"account.bin"];
	[NSKeyedArchiver archiveRootObject:account toFile:path];
}

- (IBAction) editAccount {
	[self presentModalViewController:accountEditor animated:YES];
}

#endif

- (LJAccount *)selectedAccountForAccountEditorController:(AccountEditorController *)controller {
#ifdef LITEVERSION
	return account;
#else
	return nil;
#endif
}


- (BOOL)isDublicateAccount:(NSString *)title {
	return NO;
}

- (BOOL)hasNoAccounts {
#ifdef LITEVERSION
	return !account;
#else
	return NO;
#endif
}

- (void)accountEditorController:(AccountEditorController *)controller didFinishedEditingAccount:(LJAccount *)acc {
#ifdef LITEVERSION
	account = [acc retain];
	[self saveAccount];
	[self dismissModalViewControllerAnimated:YES];
	
	ALReporter *reporter = ((JournalerAppDelegate *)[UIApplication sharedApplication].delegate).reporter;
	[reporter setObject:account.server forProperty:@"server"];
#endif
}

- (void)accountEditorControllerDidCancel:(AccountEditorController *)controller {
	[self dismissModalViewControllerAnimated:YES];
}


#ifdef LITEVERSION

- (NSString *)publisherId {
	return @"a14ae77c080ab49"; // this should be prefilled; if not, get it from www.admob.com
}

- (UIColor *)adBackgroundColor {
	return [UIColor colorWithRed:0 green:0 blue:0 alpha:1]; // this should be prefilled; if not, provide a UIColor
}


- (UIColor *)primaryTextColor {
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (UIColor *)secondaryTextColor {
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (BOOL)mayAskForLocation {
	return NO; // this should be prefilled; if not, see AdMobProtocolDelegate.h for instructions
}

// To receive test ads rather than real ads...
#ifdef DEBUG
- (BOOL)useTestAd {
	return YES;
}

- (NSString *)testAdAction {
	return @"url"; // see AdMobDelegateProtocol.h for a listing of valid values here
}
	
- (void)didReceiveAd:(AdMobView *)adView {
	NSLog(@"AdMob: Did receive ad");
}
#endif
	
- (void)didFailToReceiveAd:(AdMobView *)adView {
	CGRect frame = webView.frame;
	frame.origin.y = 0;
	frame.size.height += 48;
	webView.frame = frame;
	
//	[ljAccountView reloadData];
}


#endif
	
#pragma mark Atmiņas vadība

//- (void) clearWebViewCache {
//	for (UIWebView *lWebView in [webViews allValues]) {
//		if (lWebView != webView) {
//			[lWebView setDelegate:nil];
//			[lWebView release];
//		}
//	}
//	[webViews removeAllObjects];
//}
	
#pragma mark UIWebView vadības komandas

- (IBAction) webViewBack:(id) sender {
	[webView goBack];
}
	
- (IBAction) webViewForward:(id) sender {
	[webView goForward];
}
	
- (IBAction) webViewReload:(id) sender{
	[webView reload];
}

- (IBAction) webViewStop:(id) sender{
	[webView stopLoading];
}

- (IBAction) webViewFriends:(id) sender {
#ifndef LITEVERSION
	LJAccount *account = [dataSource selectedAccountForAccountViewController:self];
#endif
	[self loadFriendListInWebView:webView forAccount:account];
}


@end
