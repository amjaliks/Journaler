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
@synthesize navItem;

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

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	subjectField.text = nil;
	textField.text = nil;
	
	postButton.enabled = NO;
	textField.frame = CGRectMake(0, 0, 320, 167);
	textCell.frame = CGRectMake(0, 0, 320, 167);
	[self.tableView reloadData];
	//[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:0];
	
	//[subjectField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[subjectField becomeFirstResponder];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
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
		return textCell.frame.size.height;
	}
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
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
    [super dealloc];
}

- (IBAction) cancel:(id)sender {
	[delegate postEditorControllerDidFinish:self];
}

- (IBAction) post:(id)sender {
	LJAccount *account = [dataSource selectedAccountForPostEditorController:self];
	
	LJFlatGetChallenge *req = [LJFlatGetChallenge requestWithServer:account.server];
	if (![req doRequest]) {
		showErrorMessage(@"Post error", req.error);
		return;
	}
	
	LJPostEvent *login = [LJPostEvent requestWithServer:account.server user:account.user password:account.password challenge:req.challenge subject:subjectField.text event:textField.text];
	if (![login doRequest]) {
		showErrorMessage(@"Post error", login.error);
		return;
	}
	if (doneButton) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your post has been published." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		subjectField.text = nil;
		textField.text = nil;
	} else {
		[delegate postEditorControllerDidFinish:self];
	}
}

- (IBAction)done:(id)sender {
	[textField resignFirstResponder];
	[subjectField resignFirstResponder];
	navItem.navigationItem.rightBarButtonItem = postButton;
	textField.frame = CGRectMake(0, 0, 320, 315);
}

- (void)textViewDidChange:(UITextView *)textView {
	postButton.enabled = [textField.text length] > 0;
	if (doneButton) {
		navItem.navigationItem.rightBarButtonItem = doneButton;
		textField.frame = CGRectMake(0, 0, 320, 167);
	}
}

- (void)textFieldDidBeginEditing:(UITextField *)_textField {
	if (doneButton) {
		navItem.navigationItem.rightBarButtonItem = doneButton;
		textField.frame = CGRectMake(0, 0, 320, 167);
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)_textField {
	return [textField becomeFirstResponder];
}


@end

