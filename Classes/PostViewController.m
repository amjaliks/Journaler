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
#import "AccountManager.h"
#import "CommentController.h"
#import "BannerViewController.h"
#import "LJFriendsPageController.h"

@implementation PostViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// virsraksts
	self.navigationItem.title = @"Post";
	
	NSError *err;
	postTemplate = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SinglePostTemplate" ofType:@"html"] encoding:NSUTF8StringEncoding error:&err] retain];
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
			
	navigationControlItem.customView = navigationControl;
	self.navigationItem.rightBarButtonItem = navigationControlItem;
	
	self.toolbarItems = [NSArray arrayWithObjects:commentItem, flexItem, actionItem, nil];
}

- (void)viewDidUnload {
	[postTemplate release];
	[userIconPath release];
	[communityIconPath release];
	
	[imageIconReplace release];
	[videoIconReplace release];
	[lockIconReplace release];
	
	self.navigationItem.rightBarButtonItem = nil;
	self.toolbarItems = nil;

	[super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	[self.navigationController setToolbarHidden:NO animated:YES];
	
	if (post != friendsPageController.openedPost) {
		[self loadPost];
	}
}

- (void)loadPost {
	webView.alpha = 0.0f;
	
	post = friendsPageController.openedPost;

	[navigationControl setEnabled:[friendsPageController hasPreviousPost] forSegmentAtIndex:0];
	[navigationControl setEnabled:[friendsPageController hasNextPost] forSegmentAtIndex:1];
	
	self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"%d of %d", nil), [friendsPageController openedPostIndex] + 1, [friendsPageController postCount], nil];

	if (!post.rendered) {
		NSMutableString *postHtml = [postTemplate mutableCopy];
		
		NSString *userPicHtml;
		if (post.userPicURL && [post.userPicURL length]) {
			[userPicCache imageForHash:post.userPicURLHash URLString:post.userPicURL wait:NO];
			userPicHtml = [NSString stringWithFormat:@"<div class=\"userpic\"><img class=\"userpic\" src=\"file://%@\"/></div>", [userPicCache pathForCachedImage:post.userPicURLHash]];
		} else {
			userPicHtml = @"";
		}
		[postHtml replaceOccurrencesOfString:@"@userpic@" withString:userPicHtml options:0 range:NSMakeRange(0, [postHtml length])];
		[postHtml replaceOccurrencesOfString:@"@lockicon@" withString:post.isPublic ? @"" : lockIconReplace options:0 range:NSMakeRange(0, [postHtml length])];
		[postHtml replaceOccurrencesOfString:@"@subject@" withString:post.subject && [post.subject length] ? post.subject : @"(no subject)" options:0 range:NSMakeRange(0, [postHtml length])];
		[postHtml replaceOccurrencesOfString:@"@usericon@" withString:userIconPath options:0 range:NSMakeRange(0, [postHtml length])];
		[postHtml replaceOccurrencesOfString:@"@postername@" withString:post.poster options:0 range:NSMakeRange(0, [postHtml length])];
		
		NSString *journal;
		if ([post.journalType intValue] == LJJournalTypeJournal) {
			journal = @"";
		} else {
			journal = [NSString stringWithFormat:@"in <img class=\"icon\" src=\"file://%@\" /> %@", communityIconPath, post.journal];
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
		
		post.rendered = postHtml;
		
		if (![post.isRead boolValue]) {
			post.isRead = [NSNumber numberWithBool:YES];
			[model saveAll];
		}
	}
	
	[webView loadHTMLString:post.rendered baseURL:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];	
	friendsPageController.accountStateInfo.openedScreen = OpenedScreenPost;
	
#ifdef LITEVERSION
	[[BannerViewController controller] addBannerToView:self.view resizeView:webView];
#endif
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.navigationController setToolbarHidden:YES animated:YES];
}

#ifndef LITEVERSION
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIDeviceOrientationPortrait || UIDeviceOrientationIsLandscape(interfaceOrientation);
}
#endif

#pragma mark Web View Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *URL = [request URL];
	if ([[URL scheme] isEqualToString:@"about"]) {
		return YES;
	} else if ([[URL scheme] isEqualToString:@"tel"]) {
		[[UIApplication sharedApplication] openURL:URL];
		return NO;
	} else {
		[self.navigationController pushViewController:appWebViewController animated:YES];
		[appWebViewController openURL:URL account:friendsPageController.account];
		return NO;
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {
	webView.alpha = 1.0f;
}

- (IBAction)showAction {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Open", nil)
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
											   destructiveButtonTitle:nil
													otherButtonTitles:NSLocalizedString(@"Full version", nil), NSLocalizedString(@"Mobile", nil), NSLocalizedString(@"Comments", nil), nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showFromToolbar:self.navigationController.toolbar]; 
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *link = nil;
	if (buttonIndex == 0) {
		link = @"http://%@.livejournal.com/%@.html";
	} else if (buttonIndex == 1) {
		link = @"http://m.livejournal.com/read/user/%@/%@";
	} else if (buttonIndex == 2) {
		link = @"http://m.livejournal.com/read/user/%@/%@/comments#comments";
	} else {
		return;
	}
	
	[appWebViewController openURL:[NSURL URLWithString:[NSString stringWithFormat:link, post.journal, post.ditemid]] account:friendsPageController.account];
	[self.navigationController pushViewController:appWebViewController animated:YES];
}

- (IBAction)commentPost {
	CommentController *comments = [[CommentController alloc] initWithPost:post account:friendsPageController.account];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:comments];
	
	[self presentModalViewController:nav animated:YES];
	
	[nav release];
	[comments release];
}

- (IBAction)navigationChanged:(id)sender {
	if ([sender selectedSegmentIndex] == 0) {
		if ([friendsPageController hasPreviousPost]) {
			[friendsPageController openPreviousPost];
			[self loadPost];
		}
	} else {
		if ([friendsPageController hasNextPost]) {
			[friendsPageController openNextPost];
			[self loadPost];
		}
	}
}

@end
