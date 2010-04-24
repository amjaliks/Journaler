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
#import "ErrorHandling.h"
#import "AccountManager.h"
#import "NSSetAdditions.h"


@implementation PostEditorController

@synthesize subjectCell;
@synthesize textCell;

@synthesize subjectField;
@synthesize textField;

@synthesize postButton;
@synthesize doneButton;

@synthesize dataSource;
@synthesize delegate;

- (id)initWithAccount:(LJAccount *)newAccount {
	if (self = [super initWithNibName:@"PostEditorController" bundle:nil]) {
		account = [newAccount retain];
		
		UIImage *image = [UIImage imageNamed:@"newpost.png"];
		UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"New post" image:image tag:1];
		self.tabBarItem = tabBarItem;
		[tabBarItem release];
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	postButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleBordered target:self action:@selector(post:)];
	self.navigationItem.rightBarButtonItem = postButton;
	
	doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
	optionsButton = [[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonItemStyleBordered target:self action:@selector(openOptions)];

	postButton.enabled = NO;
	
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	textField.text = [[AccountManager sharedManager] valueForAccount:account.title forKey:kStateInfoNewPostText];
	subjectField.text = [[AccountManager sharedManager] valueForAccount:account.title forKey:kStateInfoNewPostSubject];
	
	postOptionsController = [[PostOptionsController alloc] initWithAccount:account];
	postOptionsController.dataSource = self;
	
	NSString *journal = [[AccountManager sharedManager] valueForAccount:account.title forKey:kStateInfoNewPostJournal];
	if (journal) {
		postOptionsController.journal = journal;
	}
	postOptionsController.security = [[AccountManager sharedManager] unsignedIntegerValueForAccount:account.title forKey:kStateInfoNewPostSecurity];
	[postOptionsController.selectedFriendGroups addObjectsFromArray:[[AccountManager sharedManager] valueForAccount:account.title forKey:kStateInfoNewPostSelectedFriendGroups]];

	[[AccountManager sharedManager] registerPostEditorController:self];
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
	[super viewWillAppear:animated];
	[self resizeTextView];
}

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
	[account release];
    [super dealloc];
}

- (IBAction) cancel:(id)sender {
	[delegate postEditorControllerDidFinish:self];
}

- (IBAction) post:(id)sender {
	if (![account.user isEqualToString:postOptionsController.journal] && postOptionsController.security == PostSecurityPrivate) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post error" message:@"Can't post private message to the community." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
		
	NSString *text = textField.text;
	if (postOptionsController.promote) {
		text = [text stringByAppendingString:@"\n\n<em><small>Posted via <a href=\"http://journalerapp.com/?utm_source=livejournal&amp;utm_medium=post-via-link&amp;utm_campaign=post-via-link\">Journaler</a>.</small></em>"];
	}
	
	LJGetChallenge *req = [LJGetChallenge requestWithServer:account.server];
	if (![req doRequest]) {
		showErrorMessage(@"Post error", decodeError(req.error));
		return;
	}
	
	LJNewEvent *event = [[LJNewEvent alloc] init];
	event.subject = subjectField.text;
	event.event = text;
	event.journal = postOptionsController.journal;
	event.security = postOptionsController.security;
	event.selectedFriendGroups = postOptionsController.selectedFriendGroups;
	event.picKeyword = postOptionsController.picKeyword;
	event.tags = postOptionsController.tags;
	event.mood = postOptionsController.mood;
	
	NSError *error;
	if ([[LJManager defaultManager] postEvent:event forAccount:account error:&error]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your post has been published." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		subjectField.text = nil;
		textField.text = nil;
		postOptionsController.picKeyword = nil;
		
		if (![postOptionsController.tags isSubsetOfSet:account.tags]) {
			NSMutableSet *tags = [[NSMutableSet alloc] initWithSet:account.tags];
			[tags addObjectsFromSet:postOptionsController.tags];
			[[AccountManager sharedManager] storeAccounts];
			
			postOptionsController.tags = nil;
			postOptionsController.mood = nil;
		}
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

- (void)textFieldDidEndEditing:(UITextField *)textField {
	return;
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
#ifndef LITEVERSION
		[self.parentViewController.navigationItem setLeftBarButtonItem:nil animated:YES];
#else 
		[self.parentViewController.navigationItem setLeftBarButtonItem:((AccountTabBarController *)self.tabBarController).accountButton animated:YES];
#endif

		[self resizeTextView];
	}
}

- (void)resizeTextView {
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	BOOL landscape = UIDeviceOrientationIsLandscape(orientation);
	
	textField.frame = CGRectMake(0, 0, landscape ? 480 : 320, editing ? (landscape ? 74 : 168) : (landscape ? 187 : 336));
}

- (LJAccount *)selectedAccount {
	return [dataSource selectedAccount];
}

- (void)saveState {
	if ([self isViewLoaded]) {
		[[AccountManager sharedManager] setValue:subjectField.text forAccount:account.title forKey:kStateInfoNewPostSubject];
		[[AccountManager sharedManager] setValue:textField.text forAccount:account.title forKey:kStateInfoNewPostText];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self.tableView setContentOffset:CGPointZero];
}

@end

