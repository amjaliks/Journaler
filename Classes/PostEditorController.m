//
//  PostEditorController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.08.
//  Copyright 2009 A25. All rights reserved.
//

#import "PostEditorController.h"
#import "LiveJournal.h"
#import "AccountsViewController.h"
#import "AccountTabBarController.h"
#import "ErrorHandler.h"
#import "AccountManager.h"
#import "NSSetAdditions.h"


@implementation PostEditorController

@synthesize accountProvider;

@synthesize subjectCell;
@synthesize textCell;

@synthesize subjectField;
@synthesize textField;

@synthesize postButton;
@synthesize doneButton;

@synthesize dataSource;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibFile bundle:bundle {
	self = [super initWithNibName:nibFile bundle:bundle];
	if (self) {
		UIImage *image = [UIImage imageNamed:@"newpost.png"];
		UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"New post", nil) image:image tag:1];
		self.tabBarItem = tabBarItem;
		[tabBarItem release];
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedString(@"New post", nil);
	
	postButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Post", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(post:)];
	self.navigationItem.rightBarButtonItem = postButton;
	
	doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
	optionsButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Options", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(openOptions)];

	postButton.enabled = NO;
	
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	postOptionsController = [[PostOptionsController alloc] initWithAccountProvider:self];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self resizeTextView];
}

#ifndef LITEVERSION
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIDeviceOrientationPortrait || UIDeviceOrientationIsLandscape(interfaceOrientation);
}
#endif



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];
	[postButton release];
	[doneButton release];
	
	[postOptionsController release];
}

- (void)viewWillAppear:(BOOL)animated {
	textField.text = self.accountStateInfo.newPostText;
	subjectField.text = self.accountStateInfo.newPostSubject;
	
	[super viewWillAppear:animated];
	[self resizeTextView];
}


#pragma mark -
#pragma mark Account Provider

- (LJAccount *)account {
    return ((id<AccountProvider>)self.parentViewController).account;
}

- (AccountStateInfo *)accountStateInfo {
    return ((id<AccountProvider>)self.parentViewController).accountStateInfo;
}


#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		return subjectCell;
	} else if (indexPath.row == 1) {
		return textCell;
	}
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		return subjectCell.frame.size.height;
	} else if (indexPath.row == 1) {
		return 336;
	}
    return 0;
}



- (void)dealloc {
    [super dealloc];
}

- (IBAction) cancel:(id)sender {
	[delegate postEditorControllerDidFinish:self];
}

- (IBAction) post:(id)sender {
	if (![self.account.user isEqualToString:self.accountStateInfo.newPostJournal] && self.accountStateInfo.newPostSecurity == LJEventSecurityPrivate) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post error" message:@"Can't post private message to the community." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
		
	NSString *text = textField.text;
	if (self.accountStateInfo.newPostPromote) {
		text = [text stringByAppendingString:@"\n\n<em><small>Posted via <a href=\"http://journalerapp.com/?utm_source=livejournal&amp;utm_medium=post-via-link&amp;utm_campaign=post-via-link\">Journaler</a>.</small></em>"];
	}
	
	LJEvent *event = [[LJEvent alloc] init];
	event.subject = subjectField.text;
	event.event = text;
	event.journal = self.accountStateInfo.newPostJournal;
	event.security = self.accountStateInfo.newPostSecurity;
	event.selectedFriendGroups = self.accountStateInfo.newPostSelectedFriendGroups;
	event.picKeyword =  self.accountStateInfo.newPostPicKeyword;
	event.tags = self.accountStateInfo.newPostTags;
	event.mood =  self.accountStateInfo.newPostMood;
	NSString *music = self.accountStateInfo.newPostMusic;
	event.music = [music length] ? music : postOptionsController.currentSong;
	event.location = self.accountStateInfo.newPostLocation;
	
	NSError *error;
	if ([client postEvent:event forAccount:self.account error:&error]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your post has been published." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		subjectField.text = nil;
		textField.text = nil;
		self.accountStateInfo.newPostSubject = nil;
		self.accountStateInfo.newPostText = nil;
		self.accountStateInfo.newPostPicKeyword = nil;
		
		if (![self.accountStateInfo.newPostTags isSubsetOfSet:self.account.tags]) {
			NSMutableSet *tags = [[NSMutableSet alloc] initWithSet:self.account.tags];
			[tags addObjectsFromSet:self.accountStateInfo.newPostTags];
			[accountManager storeAccounts];			
		}

		self.accountStateInfo.newPostTags = nil;
		self.accountStateInfo.newPostMood = nil;
		self.accountStateInfo.newPostMusic = nil;
		self.accountStateInfo.newPostLocation = nil;
	} else {
		showErrorMessage(@"Post error", decodeError([error code]));
	}
	[event release];
}

- (IBAction)done:(id)sender {
	[self endPostEditing];
}

- (void)openOptions {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:postOptionsController];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	[self startPostEditing];
	return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	if (textView == self.textField) {
		self.accountStateInfo.newPostText = self.textField.text;
	}
}

- (void)textFieldDidEndEditing:(UITextField *)aTextField {
	if (aTextField == self.subjectField) {
		self.accountStateInfo.newPostSubject = self.subjectField.text;
	}
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)_textField {
	[self startPostEditing];
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)_textField {
	return [textField becomeFirstResponder];
}

- (void)startPostEditing {
	if (!editing) {
		editing = YES;
		
		[self.parentViewController.navigationItem setRightBarButtonItem:doneButton animated:YES];
		[self.parentViewController.navigationItem setLeftBarButtonItem:optionsButton animated:YES];
		
		[self resizeTextView];
	}
}

- (void)endPostEditing {
	if (editing) {
		editing = NO;
		
		postButton.enabled = [textField.text length] > 0;

		[textField resignFirstResponder];
		[subjectField resignFirstResponder];

		[self.parentViewController.navigationItem setRightBarButtonItem:postButton animated:YES];
		[self.parentViewController.navigationItem setLeftBarButtonItem:nil animated:YES];

		[self resizeTextView];
	}
}

- (void)resizeTextView {
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	BOOL landscape = UIDeviceOrientationIsLandscape(orientation);
	
	textField.frame = CGRectMake(0, 0, landscape ? 480 : 320, editing ? (landscape ? 74 : 168) : (landscape ? 187 : 336));
}

- (void)saveState {
	if ([self isViewLoaded]) {
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self.tableView setContentOffset:CGPointZero];
}

@end
