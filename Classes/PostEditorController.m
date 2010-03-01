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

//void showErrorMessage(NSUInteger code) {
//	NSString *text;
//	if (LJErrorHostNotFound == code) {
//		text = @"Can't find server";
//	} else if (LJErrorConnectionFailed == code) {
//		text = @"Can't connect to server";
//	} else if (LJErrorInvalidUsername == code) {
//		text = @"Invalid username";
//	} else if (LJErrorInvalidPassword == code) {
//		text = @"Invalid password";
//	} else {
//		text = @"Unknown error";
//	}
//	
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login error" message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//	[alert show];
//	[alert release];
//}


@implementation PostEditorController

@synthesize subjectCell;
@synthesize textCell;

@synthesize subjectField;
@synthesize textField;

@synthesize postButton;
@synthesize doneButton;

@synthesize dataSource;
@synthesize delegate;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

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
	textField.frame = CGRectMake(0, 0, 320, 336);
	textCell.frame = CGRectMake(0, 0, 320, 336);
	[self.tableView reloadData];
	
	textField.text = [[AccountManager sharedManager] valueForAccount:account.title forKey:kStateInfoNewPostText];
	subjectField.text = [[AccountManager sharedManager] valueForAccount:account.title forKey:kStateInfoNewPostSubject];
	NSString *journal = [[AccountManager sharedManager] valueForAccount:account.title forKey:kStateInfoNewPostJournal];
	if (journal) {
		self.postOptionsController.journal = journal;
	}
	self.postOptionsController.security = [[AccountManager sharedManager] unsignedIntegerValueForAccount:account.title forKey:kStateInfoNewPostSecurity];
	[self.postOptionsController.selectedFriendGroups addObjectsFromArray:[[AccountManager sharedManager] valueForAccount:account.title forKey:kStateInfoNewPostSelectedFriendGroups]];
	
	[[AccountManager sharedManager] registerPostEditorController:self];
	
//	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//	[nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
//	[nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

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
		//return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"a"];
	}
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		return subjectCell.frame.size.height;
	} else if (indexPath.row == 1) {
		return editing ? 168 : 336;
	}
    return 0;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[account release];
    [super dealloc];
}

- (IBAction) cancel:(id)sender {
	[delegate postEditorControllerDidFinish:self];
}

- (IBAction) post:(id)sender {
	if (![account.user isEqualToString:self.postOptionsController.journal] && self.postOptionsController.security == PostSecurityPrivate) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post error" message:@"Can't post private message to the community." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
		
	NSString *text = textField.text;
	if (self.postOptionsController.promote) {
		text = [text stringByAppendingString:@"\n<p><em><small>Posted via <a href=\"http://journalerapp.com/?utm_source=livejournal&amp;utm_medium=post-via-link&amp;utm_campaign=post-via-link\">Journaler</a>.</small></em></p>"];
	}
	
	LJGetChallenge *req = [LJGetChallenge requestWithServer:account.server];
	if (![req doRequest]) {
		showErrorMessage(@"Post error", decodeError(req.error));
		return;
	}
	
	LJNewEvent *event = [[LJNewEvent alloc] init];
	event.subject = subjectField.text;
	event.event = text;
	event.journal = self.postOptionsController.journal;
	event.security = self.postOptionsController.security;
	event.selectedFriendGroups = self.postOptionsController.selectedFriendGroups;
	
	NSError *error;
	if ([[LJManager defaultManager] postEvent:event forAccount:account error:&error]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your post has been published." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		subjectField.text = nil;
		textField.text = nil;
	} else {
		showErrorMessage(@"Post error", decodeError([error code]));
	}
	[event release];
}

- (IBAction)done:(id)sender {
	[self endPostEditing];
}

- (void)openOptions {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.postOptionsController];
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

//- (void)keyboardWillShow:(NSNotification *) note {
//	[self.parentViewController.navigationItem setRightBarButtonItem:doneButton animated:YES];
//	[self.parentViewController.navigationItem setLeftBarButtonItem:optionsButton animated:YES];
//	textCell.frame = CGRectMake(0, 0, 320, 168);
//	textField.frame = CGRectMake(0, 0, 320, 168);
//	[self.tableView reloadData];
//}
//
//- (void)keyboardWillHide:(NSNotification *) note {
//	postButton.enabled = [textField.text length] > 0;
//	
//	[textField resignFirstResponder];
//	[subjectField resignFirstResponder];
//	
//	[self.parentViewController.navigationItem setRightBarButtonItem:postButton animated:YES];
//#ifndef LITEVERSION
//	[self.parentViewController.navigationItem setLeftBarButtonItem:nil animated:YES];
//#else 
//	[self.parentViewController.navigationItem setLeftBarButtonItem:((AccountTabBarController *)self.tabBarController).accountButton animated:YES];
//#endif
//	textField.frame = CGRectMake(0, 0, 320, 336);
//	textCell.frame = CGRectMake(0, 0, 320, 336);
//	[self.tableView reloadData];
//}


- (void)startPostEditing {
	if (!editing) {
		editing = YES;
		
		[self.parentViewController.navigationItem setRightBarButtonItem:doneButton animated:YES];
		[self.parentViewController.navigationItem setLeftBarButtonItem:optionsButton animated:YES];
		textCell.frame = CGRectMake(0, 0, 320, 168);
		textField.frame = CGRectMake(0, 0, 320, 168);
		[self.tableView reloadData];
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
		textField.frame = CGRectMake(0, 0, 320, 336);
		textCell.frame = CGRectMake(0, 0, 320, 336);
		[self.tableView reloadData];
	}
}

- (PostOptionsController *)postOptionsController {
	if (!postOptionsController) {
		postOptionsController = [[PostOptionsController alloc] initWithAccount:account];
		postOptionsController.dataSource = self;
	}
	
	return postOptionsController;
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

@end

