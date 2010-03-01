//
//  AccountSettingsViewController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.01.
//  Copyright 2009 A25. All rights reserved.
//

#import "AccountEditorController.h"
#import "LiveJournal.h"
#import "ErrorHandling.h"

#ifdef LITEVERSION
#import "SettingsController.h"
#endif

@implementation AccountEditorController

@synthesize usernameCell;
@synthesize passwordCell;
@synthesize serverCell;

@synthesize usernameText;
@synthesize passwordText;
@synthesize serverText;

@synthesize cancelButton;
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

#ifdef LITEVERSION
- (void)viewDidLoad {
    [super viewDidLoad];

	cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cancelButton;

	doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveAccount:)];
	self.navigationItem.rightBarButtonItem = doneButton;
}
#endif

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	LJAccount *account = [dataSource selectedAccount];
	
#ifdef LITEVERSION
	newAccount = account == nil;
#endif
	
	if (account) {
		self.title = @"Edit account";
		usernameText.text = account.user;
		passwordText.text = account.password;
		serverText.text = account.server;
	} else {
#ifdef LITEVERSION
		self.title = @"Set account";
#else
		self.title = @"Add account";
#endif
		usernameText.text = nil;
		passwordText.text = nil;
		serverText.text = nil;
	}
	
	doneButton.enabled = NO;
	self.navigationItem.leftBarButtonItem = [dataSource hasNoAccounts] ? nil : cancelButton;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[usernameText becomeFirstResponder];
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

#ifdef LITEVERSION
- (void)viewDidUnload {
	[cancelButton release];
}
#endif

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#ifdef LITEVERSION
	return 2;
#else
    return 1;
#endif
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return section == 0 ? 3 : 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			return usernameCell;
		} else if (indexPath.row == 1) {
			return passwordCell;
		} else if (indexPath.row == 2) {
			return serverCell;
		}
	} else {
		static NSString *cellId = @"settings";
		UITableViewCell *settingsCell = [tableView dequeueReusableCellWithIdentifier:cellId];
		if (!settingsCell) {
			settingsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
			settingsCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			settingsCell.textLabel.text = @"Settings";
			[settingsCell autorelease];
		}
		return settingsCell;
	}
    return nil;
}

#ifdef LITEVERSION
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1) {
		SettingsController *settings = [[SettingsController alloc] initWithNibName:@"SettingsController" bundle:nil];
		UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settings];
		
		[self presentModalViewController:nav animated:YES];
		
		[nav release];
		[settings release];
	}
}
#endif

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
#ifdef LITEVERSION
	return newAccount && section == 0 ? @"Enter username and password for your account. If using a LiveJournal clone enter the server name as well." : nil;
#else
	return @"Enter username and password for your account. If using a LiveJournal clone enter the server name as well.";
#endif
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
	//[delegate accountEditorControllerDidCancel:self];
	[self dismissModalViewControllerAnimated:YES];
}

// Saglabājam kontu
- (IBAction) saveAccount:(id)sender {
	// dažas lokālas konstantes
	//   noklusētais serveris
	static NSString *defaultServer = @"livejournal.com";
	//   www prefikss, kas jāņem nost
	static NSString *wwwPrefix = @"www.";
		
	// veicam dažas servera nosaukuma pārbaudes
	NSString *server = serverText.text;
	if (!server || ![server length]) {
		// servera nosaukums nav norādīt, tad noklusēti tas ir livejournal.com
		server = defaultServer;
	} else {
		server = [server lowercaseString];
		if ([server hasPrefix:wwwPrefix]) {
			// ja servera nosaukums sākas ar www, tad noņemam tos nost
			server = [server substringFromIndex:4];
		}
	}
	
	if ([@"dreamwidth.org" isEqualToString:server]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Dreamwidth.org currently is not supported." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	LJAccount *account = [[LJAccount alloc] init];
	account.user = [usernameText.text lowercaseString];
	account.password = passwordText.text;
	account.server = server;

	if ([dataSource isDublicateAccount:account.title]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account error" message:@"You have already added this account." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[account release];
		return;
	}
	
	NSError *error;
	if (![[LJManager defaultManager] loginForAccount:account error:&error]) {
		showErrorMessage(NSLocalizedStringFromTable(@"Login error", @"Title for login error message", kErrorStringsTable), decodeError([error code]));
		return;
	}
	
	[delegate saveAccount:account];
	
	[account release];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) textFieldChanged:(id)sender {
	doneButton.enabled = usernameText.text.length && passwordText.text.length;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == usernameText) {
		[passwordText becomeFirstResponder];
	} else if (textField == passwordText) {
		[serverText becomeFirstResponder];
	} else {
		[textField resignFirstResponder];
	}
	
	return YES;
}

@end

