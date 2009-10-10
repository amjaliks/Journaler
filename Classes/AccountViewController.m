//
//  AccountViewController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.04.
//  Copyright 2009 A25. All rights reserved.
//

#import "AccountViewController.h"
#import "LiveJournal.h"

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

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    // Return YES for supported orientations
//    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
//}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	LJAccount *account = [dataSource selectedAccountForAccountViewController:self];
	self.title = account.title;
	
	LJFlatGetChallenge *challenge = [LJFlatGetChallenge requestWithServer:account.server];
	[challenge doRequest];
	
	[otherAccountView removeFromSuperview];
	[ljAccountView removeFromSuperview];
	
	if ([@"livejournal.com" isEqualToString:[account.server lowercaseString]]) {
		LJFlatGetFriendsPage *friendPage = [LJFlatGetFriendsPage requestWithServer:account.server user:account.user password:account.password challenge:challenge.challenge];
		[friendPage doRequest];
		
		events = [friendPage.entries retain]	;
		
		[self.view addSubview:ljAccountView];
	} else {
		[self.view addSubview:otherAccountView];	

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
	return [events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"PostSummary";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"PostSummaryView" owner:self options:nil];
        cell = templateCell;
        self.templateCell = nil;
    }
	
	LJEvent *event = [events objectAtIndex:indexPath.row];
	
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:1];
	if ([event.subject length]) {
		label.text = event.subject;
	} else {
		label.text = @"no subject";
		//label.textColor = [UIColor grayColor];
	}
	
    label = (UILabel *)[cell viewWithTag:2];
	if ([event.journalName isEqualTo:event.posterName]) {
		label.text = event.journalName;
	} else {
		label.text = [NSString stringWithFormat:@"%@ in %@", event.posterName, event.journalName];
	}

	label = (UILabel *)[cell viewWithTag:3];
    label.text = event.eventPreview;
	
	CGSize size = [label sizeThatFits:label.frame.size];
	CGFloat delta = size.height - label.frame.size.height;
	label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, size.height);
	
	cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height + delta);

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
	return cell.frame.size.height;
}

@end
