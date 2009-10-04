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


@synthesize webView;
@synthesize dataSource;

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

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	LJAccount *account = [dataSource selectedAccountForAccountViewController:self];
	
	LJFlatGetChallenge *challenge = [LJFlatGetChallenge requestWithServer:account.server];
	[challenge doRequest];
	LJFlatSessionGenerate *session = [LJFlatSessionGenerate requestWithServer:account.server user:account.user password:account.password challenge:challenge.challenge];
	[session doRequest];
	
	NSDictionary *cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"ljsession", NSHTTPCookieName, session.ljsession, NSHTTPCookieValue, account.server, NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
	NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/~%@/friends", account.server, account.user]]];
	[webView loadRequest:req];
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


@end
