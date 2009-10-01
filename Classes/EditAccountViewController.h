//
//  AccountSettingsViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.01.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EditAccountViewController : UITableViewController {
	UITableViewCell *usernameCell;
	UITableViewCell *passwordCell;
	UITableViewCell *serverCell;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *usernameCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *passwordCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *serverCell;

@end
