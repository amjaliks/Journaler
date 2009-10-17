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

enum {
	PSSubject = 1,
	PSAuthor,
	PSDateTimeReplies,
	PSText,
	PSUserPic,
	PSCommunityIn,
	PSCommunityIcon,
	PSCommunityName
};

@implementation AccountViewController

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

@synthesize templateCell;

@synthesize dataSource;

@synthesize postEditorController;
@synthesize postViewController;

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
	
	userPicCache = [[UserPicCache alloc] init];
}


// Override to allow orientations other than the default portrait orientation.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    // Return YES for supported orientations
//    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
//}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
		
	LJAccount *account = [dataSource selectedAccountForAccountViewController:self];
	self.title = account.user;

	[otherAccountView removeFromSuperview];
	[ljAccountView removeFromSuperview];
	
	if ([@"livejournal.com" isEqualToString:[account.server lowercaseString]]) {
		[self.view addSubview:ljAccountView];
		if (previousAccount != account) {
			previousAccount = account;
			Model *model = ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate]).model;
			posts = [[model findPostsByAccount:account.title] mutableCopy];
			[ljAccountView reloadData];
			[ljAccountView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
		}
	} else {
		[self.view addSubview:otherAccountView];	

		LJFlatGetChallenge *challenge = [LJFlatGetChallenge requestWithServer:account.server];
		[challenge doRequest];
		
		LJFlatSessionGenerate *session = [LJFlatSessionGenerate requestWithServer:account.server user:account.user password:account.password challenge:challenge.challenge];
		[session doRequest];
		
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
	}
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	LJAccount *account = [dataSource selectedAccountForAccountViewController:self];
	
	if (!account.synchronized && [@"livejournal.com" isEqualToString:[account.server lowercaseString]]) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

		LJGetChallenge *challenge = [LJGetChallenge requestWithServer:account.server];
		[challenge doRequest];
 		NSString *c = [challenge.challenge retain];
		//LJFlatGetEvents *friendPage = [LJFlatGetEvents requestWithServer:account.server user:account.user password:account.password challenge:challenge.challenge];		
		LJGetFriendsPage *friendPage = [LJGetFriendsPage requestWithServer:account.server user:account.user password:account.password challenge:c];
		[friendPage doRequest];
		
		NSArray *events = [friendPage.entries retain];
		
		NSUInteger idx = 0;
		
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
				[posts insertObject:post atIndex:idx];
				idx++;
			}
			post.dateTime = event.datetime;
			post.subject = event.subject;
			post.text = event.event;
			post.replyCount = [NSNumber numberWithInt:event.replyCount];
			post.userPicURL = event.userPicUrl;
			
			[model saveAll];
		}
		
		[self.ljAccountView reloadData];

		account.synchronized = YES;

		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	};
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


- (void)dealloc {
    [super dealloc];
	
	[userPicCache release];
}

- (IBAction) goToUpdate {
	[self presentModalViewController:postEditorController animated:YES];
}

- (LJAccount *)selectedAccountForPostEditorController:(PostEditorController *)controller {
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
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"PostSummaryView" owner:self options:nil];
        cell = templateCell;
        self.templateCell = nil;
    }
	
	Post *post = [posts objectAtIndex:indexPath.row];
	
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:PSSubject];
	if ([post.subject length]) {
		label.text = post.subject;
	} else {
		label.text = @"no subject";
	}
	
    label = (UILabel *)[cell viewWithTag:PSAuthor];
	label.text = post.poster;
//	if ([event.journalName isEqualToString:event.posterName]) {
//		label.text = event.journalName;
//	} else {
//		label.text = [NSString stringWithFormat:@"%@ in %@", event.posterName, event.journalName];
//	}
	CGRect frame = label.frame;
	CGSize size = [label sizeThatFits:frame.size];
	if ([@"C" isEqualToString:post.journalType] && size.width > 150) {
		size.width = 150;
	}
	frame.size.width = size.width;
	label.frame = frame;
	CGFloat last = frame.origin.x + frame.size.width;
	
	UILabel *communityIn = (UILabel *)[cell viewWithTag:PSCommunityIn];
	UIImageView *communityIcon = (UIImageView *)[cell viewWithTag:PSCommunityIcon];
	UILabel *communityName = (UILabel *)[cell viewWithTag:PSCommunityName];
	if ([@"C" isEqualToString:post.journalType] || [@"N" isEqualToString:post.journalType]) {
		communityIn.hidden = NO;
		communityIcon.hidden = NO;
		communityName.hidden = NO;
		
		frame = communityIn.frame;
		frame.origin.x = last + 1;
		communityIn.frame = frame;
		last = frame.origin.x + frame.size.width;
		
		frame = communityIcon.frame;
		frame.origin.x = last + 1;
		communityIcon.frame = frame;
		last = frame.origin.x + frame.size.width;

		communityName.text = post.journal;
		frame = communityName.frame;
		frame.origin.x = last + 2;
		frame.size.width = 294 - frame.origin.x;
		communityName.frame = frame;
	} else {
		communityIn.hidden = YES;
		communityIcon.hidden = YES;
		communityName.hidden = YES;
	}

	label = (UILabel *)[cell viewWithTag:PSText];
    label.text = post.textPreview;
	
//	CGSize size = [label sizeThatFits:label.frame.size];
//	CGFloat delta = size.height - label.frame.size.height;
//	label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, size.height);
//	
//	cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height + delta);

	NSDateFormatter *f = [[NSDateFormatter alloc] init];
	[f setDateStyle:NSDateFormatterShortStyle];
	[f setTimeStyle:NSDateFormatterShortStyle];
	
	label = (UILabel *)[cell viewWithTag:PSDateTimeReplies];
    label.text = [NSString stringWithFormat:@"%@, %d replies", [f stringFromDate:post.dateTime], [post.replyCount integerValue]];
	[f release];
	
	UIImageView *imageView = (UIImageView *)[cell viewWithTag:PSUserPic];
	imageView.image = [userPicCache userPicFromURL:post.userPicURL];
	
	return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	UITableViewCell *cell = [tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
//	return cell.frame.size.height;
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	selectedPost = [posts objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:postViewController animated:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (Post *) selectEventForPostViewController:(PostViewController *)controller {
	return selectedPost;
}


@end


@implementation UserPicCache

- (id) init {
	if (self = [super init]) {
		cache = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
	[cache release];
}
	
- (UIImage *) userPicFromURL:(NSString *)url {
	UIImage *image = [cache valueForKey:url];
	if (image) {
		return image;
	} else {
		NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
		
		NSURLResponse *res;
		NSError *err;
		NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
		
		image = [[UIImage alloc] initWithData:data];
		[cache setValue:image forKey:url];
		
		return image;
	}
}

@end
