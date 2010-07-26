//
//  AccountSettingsViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.01.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AccountsViewController.h"

@class LJAccount;

@interface AccountEditorController : UITableViewController<UITextFieldDelegate> {
	IBOutlet AccountsViewController *accountsViewController;

	IBOutlet UITableViewCell *usernameCell;
	IBOutlet UITableViewCell *passwordCell;
	IBOutlet UITableViewCell *serverCell;
	
	IBOutlet UITextField *usernameText;
	IBOutlet UITextField *passwordText;
	IBOutlet UITextField *serverText;
	
	IBOutlet UIBarButtonItem *cancelButton;
	IBOutlet UIBarButtonItem *doneButton;
}

- (IBAction) cancel:(id)sender;
- (IBAction) saveAccount:(id)sender;
- (IBAction) textFieldChanged:(id)sender;

@end
