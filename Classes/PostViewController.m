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

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (id)initWithPost:(Post *)newPost account:(LJAccount *)newAccount {
	if (self = [super init]) {
		post = [newPost retain];
		account = [newAccount retain];		
		
		// komentāru poga
		UIBarButtonItem *commentsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"comments.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(openComments)];
		self.navigationItem.rightBarButtonItem = commentsButton;
		[commentsButton release];
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	postTemplate = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SinglePostTemplate" ofType:@"html"]] retain];
	userIconPath = [[[NSBundle mainBundle] pathForResource:@"user" ofType:@"png"] retain];
	communityIconPath = [[[NSBundle mainBundle] pathForResource:@"community" ofType:@"png"] retain];

	NSString *imageIconPath = [[[NSBundle mainBundle] pathForResource:@"image" ofType:@"png"] retain];
	imageIconReplace = [[NSString stringWithFormat:@"<img src=\"file://%@\" class=\"icon\"/>", imageIconPath] retain];
	[imageIconPath release];
	
	NSString *videoIconPath = [[[NSBundle mainBundle] pathForResource:@"video" ofType:@"png"] retain];
	videoIconReplace = [[NSString stringWithFormat:@"<img src=\"file://%@\" class=\"icon\"/>", videoIconPath] retain];
	[videoIconPath release];

	NSString *lockIconPath = [[NSBundle mainBundle] pathForResource:@"lock" ofType:@"png"];
	lockIconReplace = [[NSString stringWithFormat:@"<img src=\"file://%@\" class=\"icon\"/> ", lockIconPath] retain];
	
	webView = [[UIWebView alloc] initWithFrame:self.view.frame];
	webView.delegate = self;
	self.view = webView;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];

	if (!post.rendered) {
		post.rendered = YES;
		
		NSMutableString *postHtml = [postTemplate mutableCopy];

		NSString *userPicHtml;
		if (post.userPicURL && [post.userPicURL length]) {
			[APP_USER_PIC_CACHE userPicForPost:post];
			userPicHtml = [NSString stringWithFormat:@"<div class=\"userpic\"><img class=\"userpic\" src=\"file://%@\"/></div>", [APP_USER_PIC_CACHE pathForCacheImage:post.userPicURLHash]];
		} else {
			userPicHtml = @"";
		}
		[postHtml replaceOccurrencesOfString:@"@userpic@" withString:userPicHtml options:0 range:NSMakeRange(0, [postHtml length])];
		[postHtml replaceOccurrencesOfString:@"@lockicon@" withString:post.isPublic ? @"" : lockIconReplace options:0 range:NSMakeRange(0, [postHtml length])];
		[postHtml replaceOccurrencesOfString:@"@subject@" withString:post.subject && [post.subject length] ? post.subject : @"(no subject)" options:0 range:NSMakeRange(0, [postHtml length])];
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
		[postHtml replaceOccurrencesOfString:@"@replycount@" withString:[NSString stringWithFormat:@"%@%@", post.replyCount, post.updated ? @"" : @"*"] options:0 range:NSMakeRange(0, [postHtml length])];

		[postHtml replaceOccurrencesOfString:@"@post@" withString:post.textView options:0 range:NSMakeRange(0, [postHtml length])];
		
		[postHtml replaceOccurrencesOfString:@"@imageicon@" withString:imageIconReplace options:0 range:NSMakeRange(0, [postHtml length])];
		[postHtml replaceOccurrencesOfString:@"@videoicon@" withString:videoIconReplace options:0 range:NSMakeRange(0, [postHtml length])];

		[webView loadHTMLString:postHtml baseURL:nil];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	webView.delegate = nil;
	[webView release];
}

- (void)dealloc {
	[postTemplate release];
	[userIconPath release];
	[communityIconPath release];
	
	[post release];
	[account release];
	
    [super dealloc];
}

#pragma mark Pogas

- (void)openComments {
	NSURL *URL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://m.livejournal.com/read/user/%@/%@/comments#comments", post.journal, post.ditemid]];
	[self.navigationController pushViewController:APP_WEB_VIEW_CONTROLLER animated:YES];
	[APP_WEB_VIEW_CONTROLLER openURL:URL account:account];
	[URL release];
}

#pragma mark Web View Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *URL = [request URL];
	if ([[URL scheme] isEqualToString:@"about"]) {
		return YES;
	} else if ([[URL scheme] isEqualToString:@"tel"]) {
		[[UIApplication sharedApplication] openURL:URL];
		return NO;
	} else {
		WebViewController *webViewController = APP_WEB_VIEW_CONTROLLER;
		[self.navigationController pushViewController:webViewController animated:YES];
		[webViewController openURL:URL account:account];
		return NO;
	}
}


@end
