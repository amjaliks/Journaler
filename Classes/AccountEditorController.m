//
//  AccountSettingsViewController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.01.
//  Copyright 2009 A25. All rights reserved.
//

#import "AccountEditorController.h"
#import "LiveJournal.h"
#import "ErrorHandler.h"

@implementation AccountEditorController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	if (accountsViewController.account) {
		[passwordText becomeFirstResponder];
	} else {
		[usernameText becomeFirstResponder];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	if (accountsViewController.account) {
		self.title = @"Edit account";
		
		usernameText.text = accountsViewController.account.user;
		passwordText.text = accountsViewController.account.password;
		serverText.text = accountsViewController.account.server;
		
		usernameText.textColor = [UIColor darkGrayColor];
		serverText.textColor = [UIColor darkGrayColor];
		usernameText.enabled = NO;
		serverText.enabled = NO;
	} else {
		self.title = @"Add account";
		usernameText.text = nil;
		passwordText.text = nil;
		serverText.text = nil;
		
		usernameText.textColor = [UIColor blackColor];
		serverText.textColor = [UIColor blackColor];
		usernameText.enabled = YES;
		serverText.enabled = YES;
	}
	
	doneButton.enabled = NO;
	self.navigationItem.leftBarButtonItem = [accountManager.accounts count] ? cancelButton : nil;
}

#ifndef LITEVERSION
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIDeviceOrientationPortrait || UIDeviceOrientationIsLandscape(interfaceOrientation);
}
#endif

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

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

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (accountsViewController.account) {
		return nil;
	} else {
		return NSLocalizedString(@"Enter username and password for your account. If using a LiveJournal clone enter the server name as well.", nil);
	}
}

- (IBAction)cancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

// Saglabājam kontu
- (IBAction)saveAccount:(id)sender {
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
		showErrorMessage(NSLocalizedString(@"Sorry!", nil), NSLocalizedString(@"Dreamwidth.org is not supported.", nil));
		return;
	}
	
	BOOL newAccount;
	LJAccount *account;
	account = [accountsViewController.account retain];
	if (account) {
		newAccount = NO;
	} else {
		newAccount = YES;
		account = [[LJAccount alloc] init];
		account.user = [usernameText.text lowercaseString];
		account.server = server;
		
		if ([accountManager accountExists:account.title]) {
			showErrorMessage(NSLocalizedString(@"Account error", nil), NSLocalizedString(@"You have already added this account.", nil));
			[account release];
			return;
		}
	}
	account.password = passwordText.text;
	
	NSError *error;
	if (![client loginForAccount:account error:&error]) {
		showErrorMessage(NSLocalizedString(@"Login error", nil), decodeError([error code]));
		[account release];
		return;
	}
	
	if (newAccount) {
		[accountManager addAccount:account];
		[accountsViewController.tableView reloadData];
		[accountsViewController openAccountAtIndex:[accountManager.accounts count] - 1 animated:NO];
	}
	
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
	} else if (textField == serverText) {
		[self saveAccount:nil];
	} else {
		[textField resignFirstResponder];
	}
	
	return YES;
}

@end

