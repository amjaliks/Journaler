//
//  CommentController.m
//  Journaler
//
//  Created by Natālija Dudareva on 7/6/10.
//  Copyright 2010 A25. All rights reserved.
//

#import "CommentController.h"
#import "LJComment.h"
#import "Post.h"
#import "LJManager.h"
#import "ErrorHandling.h"


@implementation CommentController

- (id)initWithPost:(Post *)newPost account:(LJAccount *)newAccount {
	if (self = [super init]) {
		account = [newAccount retain];
		post = [newPost retain];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedString(@"Comment", nil);

	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
		
	postButton  = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Post", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(post:)];
	self.navigationItem.rightBarButtonItem = postButton;
	postButton.enabled = NO;
	
	CGRect frame = self.view.bounds;
	textView = [[UITextView alloc] initWithFrame:frame];
	textView.delegate = self;
	textView.font = [UIFont systemFontOfSize:17.0f];
	textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:textView];

	// tastatūras notikumi
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];	 
	[notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[textView becomeFirstResponder];
}

#ifndef LITEVERSION
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIDeviceOrientationPortrait || UIDeviceOrientationIsLandscape(interfaceOrientation);
}
#endif

- (void)viewDidUnload {
    [super viewDidUnload];

	self.navigationItem.rightBarButtonItem = nil;
	[postButton release];

	[textView removeFromSuperview];
	[textView release];
}


- (void)dealloc {
	[account release];
	[post release];
	
    [super dealloc];
}

- (void)cancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)post:(id)sender {
	LJComment *comment = [[LJComment alloc] init];
	comment.commentBody = textView.text;
	comment.ditemid = post.ditemid;
	comment.journal = post.journal;
	
	NSError *error;
	if ([[LJManager defaultManager] addComment:comment forAccount:account error:&error]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your post has been published." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		showErrorMessage(@"Post error", decodeError([error code]));
	}
	
	[comment release];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)textViewDidChange:(UITextView *)view {
	if ([view.text length] > 0) {
		postButton.enabled = YES;
	} else {
		postButton.enabled = NO;
	}

}

#pragma mark -
#pragma mark Tastatūras notikumi

- (void)keyboardWillShow:(NSNotification *)notification {
	CGRect frame = textView.frame;
	CGRect keyboardBounds;
	
    [[notification.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue:&keyboardBounds];
    frame.size.height -= keyboardBounds.size.height;
    textView.frame = frame;
}

- (void)keyboardDidHide:(NSNotification *)notification {
	CGRect frame = textView.frame;
	CGRect keyboardBounds;
	
    [[notification.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue:&keyboardBounds];
    frame.size.height += keyboardBounds.size.height;
    textView.frame = frame;
}



@end
