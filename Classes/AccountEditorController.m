//
//  AccountSettingsViewController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.01.
//  Copyright 2009 A25. All rights reserved.
//

#import "AccountEditorController.h"
#import "LiveJournal.h"


void showErrorMessage(NSString *title, NSUInteger code) {
	NSString *text;
	if (LJErrorHostNotFound == code) {
		text = @"Can't find server";
	} else if (LJErrorConnectionFailed == code) {
		text = @"Can't connect to server";
	} else if (LJErrorInvalidUsername == code) {
		text = @"Invalid username";
	} else if (LJErrorInvalidPassword == code) {
		text = @"Invalid password";
	} else {
		text = @"Unknown error";
	}
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}


@implementation AccountEditorController

@synthesize usernameCell;
@synthesize passwordCell;
@synthesize serverCell;

@synthesize usernameText;
@synthesize passwordText;
@synthesize serverText;

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
/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	LJAccount *account = [dataSource selectedAccountForAccountEditorController:self];
	
	if (account) {
		self.title = @"Edit account";
		usernameText.text = account.user;
		passwordText.text = account.password;
		serverText.text = account.server;
	} else {
		self.title = @"Add account";
		usernameText.text = nil;
		passwordText.text = nil;
		serverText.text = nil;
	}
	
	doneButton.enabled = NO;	
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[usernameText becomeFirstResponder];
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
    return 3;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		return usernameCell;
	} else if (indexPath.row == 1) {
		return passwordCell;
	} else if (indexPath.row == 2) {
		return serverCell;
	}
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return @"Enter username and password for your account. If you used some LJ-clone server, enter server too.";
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
	[delegate accountEditorControllerDidCancel:self];
}

// Saving account. Handles event of "Done".
- (IBAction) saveAccount:(id)sender {
	NSString *server = serverText.text;
	if (![server length]) {
		server = @"livejournal.com";
	}
	
	LJFlatGetChallenge *req = [LJFlatGetChallenge requestWithServer:server];
	if (![req doRequest]) {
		showErrorMessage(@"Login error", req.error);
		return;
	}
	
	LJFlatLogin *login = [LJFlatLogin requestWithServer:server user:usernameText.text password:passwordText.text challenge:req.challenge];
	if (![login doRequest]) {
		showErrorMessage(@"Login error", login.error);
		return;
	}
	
	LJAccount *account = [[LJAccount alloc] init];
	account.user = usernameText.text;
	account.password = passwordText.text;
	account.server = server;
	
	[delegate accountEditorController:self didFinishedEditingAccount:account];
	
	[account release];
}

// Check text fields. If required fields has some text, than makes "Done" enabled.
// Mandatory fields are: username and password.
- (IBAction) textFieldChanged:(id)sender {
	doneButton.enabled = usernameText.text.length && passwordText.text.length;
}

@end

