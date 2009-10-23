//
//  AccountSettingsViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.01.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

void showErrorMessage(NSString *title, NSUInteger code);

@class LJAccount;
@protocol AccountEditorControllerDataSource, AccountEditorControllerDelegate;


@interface AccountEditorController : UITableViewController {
	UITableViewCell *usernameCell;
	UITableViewCell *passwordCell;
	UITableViewCell *serverCell;
	
	UITextField *usernameText;
	UITextField *passwordText;
	UITextField *serverText;
	
	UIBarButtonItem *cancelButton;
	UIBarButtonItem *doneButton;
	
	id<AccountEditorControllerDataSource> dataSource;
	id<AccountEditorControllerDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *usernameCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *passwordCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *serverCell;

@property (nonatomic, retain) IBOutlet UITextField *usernameText;
@property (nonatomic, retain) IBOutlet UITextField *passwordText;
@property (nonatomic, retain) IBOutlet UITextField *serverText;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, retain) IBOutlet id<AccountEditorControllerDataSource> dataSource;
@property (nonatomic, retain) IBOutlet id<AccountEditorControllerDelegate> delegate;

- (IBAction) cancel:(id)sender;
- (IBAction) saveAccount:(id)sender;
- (IBAction) textFieldChanged:(id)sender;

@end


@protocol AccountEditorControllerDataSource<NSObject> 

- (LJAccount *)selectedAccountForAccountEditorController:(AccountEditorController *)controller;
- (BOOL)isDublicateAccount:(NSString *)title;
- (BOOL)hasNoAccounts;

@end


@protocol AccountEditorControllerDelegate<NSObject> 

@optional
- (void)accountEditorController:(AccountEditorController *)controller didFinishedEditingAccount:(LJAccount *)account;
- (void)accountEditorControllerDidCancel:(AccountEditorController *)controller;

@end

