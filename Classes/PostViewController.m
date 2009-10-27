//
//  PostViewController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.13.
//  Copyright 2009 A25. All rights reserved.
//

#import "PostViewController.h"
#import "LiveJournal.h"
#import "Model.h"
#import "JournalerAppDelegate.h"
#import "UserPicCache.h"
#import "NSStringAdditions.h"
#import "WebViewController.h"

@implementation PostViewController

@synthesize webViewController;
@synthesize waitView;

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	postTemplate = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SinglePostTemplate" ofType:@"html"]] retain];
	userIconPath = [[[NSBundle mainBundle] pathForResource:@"user" ofType:@"png"] retain];
	communityIconPath = [[[NSBundle mainBundle] pathForResource:@"community" ofType:@"png"] retain];

	NSString *imageIconPath = [[[NSBundle mainBundle] pathForResource:@"image" ofType:@"png"] retain];
	imageIconReplace = [[NSString stringWithFormat:@"<img src=\"file://%@\" class=\"icon\"/>", imageIconPath] retain];
	[imageIconPath release];
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)viewWillAppear:(BOOL)animated {
	if (lastWebView) {
		[lastWebView removeFromSuperview];
		[lastWebView release];
	}
	[self.view addSubview:waitView];
}

- (void)viewDidAppear:(BOOL)animated {
	Post *post = [dataSource selectEventForPostViewController:self];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"png"];
	path = [path stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	
	NSLog(path);
	
	UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
	webView.delegate = self;
	
	NSMutableString *postHtml = [postTemplate mutableCopy];

	NSString *userPicHtml;
	if (post.userPicURL && [post.userPicURL length]) {
		UserPicCache *userPicCache = ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate]).userPicCache;
		userPicHtml = [NSString stringWithFormat:@"<div class=\"userpic\"><img class=\"userpic\" src=\"data:image/png;base64,%@\"/></div>", [userPicCache base64DataFromURL:post.userPicURL]];
	} else {
		userPicHtml = @"";
	}
	[postHtml replaceOccurrencesOfString:@"@userpic@" withString:userPicHtml options:0 range:NSMakeRange(0, [postHtml length])];
	[postHtml replaceOccurrencesOfString:@"@subject@" withString:post.subject options:0 range:NSMakeRange(0, [postHtml length])];
	[postHtml replaceOccurrencesOfString:@"@usericon@" withString:userIconPath options:0 range:NSMakeRange(0, [postHtml length])];
	[postHtml replaceOccurrencesOfString:@"@postername@" withString:post.poster options:0 range:NSMakeRange(0, [postHtml length])];

	NSString *journal;
	if ([@"C" isEqualToString:post.journalType] || [@"N" isEqualToString:post.journalType]) {
		journal = [NSString stringWithFormat:@"in <img class=\"icon\" src=\"file://%@\" /> %@", communityIconPath, post.journal];
	} else {
		journal = @"";
	}
	[postHtml replaceOccurrencesOfString:@"@journalname@" withString:journal options:0 range:NSMakeRange(0, [postHtml length])];
	
	NSDateFormatter *f = [[NSDateFormatter alloc] init];
	[f setDateStyle:NSDateFormatterShortStyle];
	[f setTimeStyle:NSDateFormatterShortStyle];
	[postHtml replaceOccurrencesOfString:@"@datetime@" withString:[f stringFromDate:post.dateTime] options:0 range:NSMakeRange(0, [postHtml length])];
	[f release];
	[postHtml replaceOccurrencesOfString:@"@replycount@" withString:[post.replyCount stringValue] options:0 range:NSMakeRange(0, [postHtml length])];

	[postHtml replaceOccurrencesOfString:@"@post@" withString:post.textView options:0 range:NSMakeRange(0, [postHtml length])];
	[postHtml replaceOccurrencesOfString:@"@imageicon@" withString:imageIconReplace options:0 range:NSMakeRange(0, [postHtml length])];

	[webView loadHTMLString:postHtml baseURL:nil];
	//[webView loadHTMLString:[NSString stringWithFormat:template, post.subject, post.textView] baseURL:nil];
	//[webView loadHTMLString:[NSString stringWithFormat:@"<img src=\"file://%@\" />", path] baseURL:nil];
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
	[postTemplate release];
	[userIconPath release];
	[communityIconPath release];
    [super dealloc];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *url = [request URL];
	if ([[url scheme] isEqualToString:@"about"]) {
		return YES;
	} else if ([[url scheme] isEqualToString:@"tel"]) {
		[[UIApplication sharedApplication] openURL:url];
		return NO;
	} else {
		//[[UIApplication sharedApplication] openURL:url];
		[self openInWebView:[url absoluteString]];
		return NO;
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[waitView removeFromSuperview];
	[self.view addSubview:webView];
	lastWebView = webView;
}

- (void) openInWebView:(NSString *)url {
	[self.navigationController pushViewController:webViewController animated:YES];
	[webViewController openURL:url]; 
}


- (IBAction) openWebView:(id)sender {
	Post *post = [dataSource selectEventForPostViewController:self];
	LJAccount *account = [dataSource selectedAccountForPostViewController:self];
	[self openInWebView:[NSString stringWithFormat:@"http://m.livejournal.com/login?mode=get&login=%@&password=%@&back_uri=/read/user/%@/%@/comments#comments", account.user, account.password, post.journal, post.ditemid]];
}

@end
