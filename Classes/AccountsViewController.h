//
//  AccountsViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.01.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AccountsViewController : UITableViewController {
	UIViewController *editAccountViewController;
}

@property (nonatomic, retain) IBOutlet UIViewController *editAccountViewController;

- (IBAction) addAccount:(id)sender;

@end
