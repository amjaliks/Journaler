//
//  AccountsViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.01.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountEditorController.h"
#import "AccountViewController.h"

// kontu saraksta kontrolieris
@interface AccountsViewController : UITableViewController<AccountEditorControllerDataSource, AccountEditorControllerDelegate> {
	UIViewController *editAccountViewController;
	UIViewController *accountViewController;
	
	UITableView *table;
	
	NSMutableArray *accounts;
	LJAccount *selectedAccount;
	NSString *selectedAccountTitle;
	
	// kešs inicializēto kontrolierus glabāšanai
	NSMutableDictionary *cacheTabBarControllers;
}

@property (nonatomic, retain) IBOutlet UIViewController *editAccountViewController;
@property (nonatomic, retain) IBOutlet UIViewController *accountViewController;

@property (nonatomic, retain) IBOutlet UITableView *table;

- (void) saveAccounts;

- (IBAction) addAccount:(id)sender;

- (void) sendReport;

@end
