//
//  AccountSettingsViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.01.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AccountEditorController : UITableViewController {
	UITableViewCell *usernameCell;
	UITableViewCell *passwordCell;
	UITableViewCell *serverCell;
	
	UITextField *usernameText;
	UITextField *passwordText;
	UITextField *serverText;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *usernameCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *passwordCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *serverCell;

@property (nonatomic, retain) IBOutlet UITextField *usernameText;
@property (nonatomic, retain) IBOutlet UITextField *passwordText;
@property (nonatomic, retain) IBOutlet UITextField *serverText;

- (IBAction) saveAccount:(id)sender;

@end
