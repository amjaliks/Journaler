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

@implementation AccountViewController

@synthesize tabBar;
@synthesize masterView;

@synthesize ljAccountView;
@synthesize otherAccountView;

@synthesize webView;

@synthesize toolbar;
@synthesize backButton;
@synthesize fixedSpace;
@synthesize forwardButton;
@synthesize flexibleSpace;
@synthesize refreshButton;
@synthesize stopButton;

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
	//[self.view addSubview:tabBar.view];
#ifdef LITEVERSION
	account = [self loadAccount];
	accountButton = [[UIBarButtonItem alloc] initWithTitle:@"Account" style:UIBarButtonItemStyleBordered target:self action:@selector(editAccount)];
	self.navigationItem.leftBarButtonItem = accountButton;
#endif
}


// Override to allow orientations other than the default portrait orientation.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    // Return YES for supported orientations
//    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
//}


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
//		if (account.synchronized) {
//			[self.masterView addSubview:ljAccountView];
//		}
		self.navigationItem.rightBarButtonItem = refreshPostsButton;
	} else {
		self.navigationItem.rightBarButtonItem = newPostOther;
		
		[self.view addSubview:otherAccountView];	

		LJFlatGetChallenge *challenge = [LJFlatGetChallenge requestWithServer:account.server];
		if ([challenge doRequest]) {
		
			LJFlatSessionGenerate *session = [LJFlatSessionGenerate requestWithServer:account.server user:account.user password:account.password challenge:challenge.challenge];
			if ([session doRequest]) {
				NSDictionary *cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"ljsession", NSHTTPCookieName, session.ljsession, NSHTTPCookieValue, [NSString stringWithFormat:@".%@", account.server], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
				NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
				[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];

				cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"ljmastersession", NSHTTPCookieName, session.ljsession, NSHTTPCookieValue, [NSString stringWithFormat:@".%@", account.server], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
				cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
				[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];

				NSArray *parts = [session.ljsession componentsSeparatedByString:@":"];
				cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"ljloggedin", NSHTTPCookieName, [NSString stringWithFormat:@"%@:%@", [parts objectAtIndex:1], [parts objectAtIndex:2]], NSHTTPCookieValue, [NSString stringWithFormat:@".%@", account.server], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
				cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
				[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
				
				NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/~%@/friends", account.server, account.user]]];
				[webView loadRequest:req];
			} else {
				showErrorMessage(@"Friend page error", session.error);
			}
		} else {
			showErrorMessage(@"Friend page error", challenge.error);
		}
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

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

#ifndef LITEVERSION
	LJAccount *account = [dataSource selectedAccountForAccountViewController:self];
#endif
	
	if ([@"livejournal.com" isEqualToString:[account.server lowercaseString]]) {
		if (!account.synchronized) {
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
			
			[ljAccountView reloadData];
			[ljAccountView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];

			account.synchronized = YES;
			refreshPostsButton.enabled = YES;

			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		};
		[self.masterView addSubview:ljAccountView];
		
		[self scrollViewDidEndDecelerating:ljAccountView];
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
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	refreshPostsButton.enabled = YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


//- (void)dealloc {
//    [super dealloc];
//}

- (IBAction) goToUpdate {
	[self presentModalViewController:postEditorController animated:YES];
}

- (LJAccount *)selectedAccountForPostEditorController:(PostEditorController *)controller {
	return [dataSource selectedAccountForAccountViewController:self];
}

- (LJAccount *) selectedAccountForPostViewController:(PostViewController *)controller {
	return [dataSource selectedAccountForAccountViewController:self];
}

- (void)postEditorControllerDidFinish:(PostEditorController *)controller {
	[self dismissModalViewControllerAnimated:YES];
}


- (void)webViewDidStartLoad:(UIWebView *)webView_ {
	backButton.enabled = webView.canGoBack;
	forwardButton.enabled = webView.canGoForward;
	
	[toolbar setItems:[NSArray arrayWithObjects:
					   backButton, fixedSpace, forwardButton, flexibleSpace, stopButton, nil]
			 animated:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView_ {
	backButton.enabled = webView.canGoBack;
	forwardButton.enabled = webView.canGoForward;

	[toolbar setItems:[NSArray arrayWithObjects:
					   backButton, fixedSpace, forwardButton, flexibleSpace, refreshButton, nil]
									   animated:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"PostSummary";
	
    PostSummaryCell *cell = (PostSummaryCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"PostSummaryView" owner:self options:nil];
        cell = templateCell;
		cell.tableView = tableView;
        self.templateCell = nil;
    }
	
	Post *post = [posts objectAtIndex:indexPath.row];
	cell.post = post;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	selectedPost = [posts objectAtIndex:indexPath.row];
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
	for (PostSummaryCell *cell in cells) {
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

- (LJAccount *)selectedAccountForAccountEditorController:(AccountEditorController *)controller {
	return account;
}

- (BOOL)isDublicateAccount:(NSString *)title {
	return NO;
}

- (BOOL)hasNoAccounts {
	return !account;
}

- (void)accountEditorController:(AccountEditorController *)controller didFinishedEditingAccount:(LJAccount *)acc {
	account = [acc retain];
	[self saveAccount];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)accountEditorControllerDidCancel:(AccountEditorController *)controller {
	[self dismissModalViewControllerAnimated:YES];
}

#endif

@end
