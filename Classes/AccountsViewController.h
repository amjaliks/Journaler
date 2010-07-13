//
//  AccountsViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.01.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountEditorController.h"

// kontu saraksta kontrolieris
@interface AccountsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, AccountEditorControllerDataSource, AccountEditorControllerDelegate> {
	UINavigationController *editAccountViewController;
	UIViewController *accountViewController;
	
	UITableView *table;
	
	NSMutableArray *accounts;
	LJAccount *selectedAccount;
	NSString *selectedAccountTitle;
	
	// labošanas poga
	UIBarButtonItem *editButtonItem;
	
	// kešs inicializēto kontrolierus glabāšanai
	NSMutableDictionary *cacheTabBarControllers;
	
	IBOutlet UIBarButtonItem *settingsButton;
}

@property (nonatomic, retain) IBOutlet UIViewController *editAccountViewController;
@property (nonatomic, retain) IBOutlet UIViewController *accountViewController;

@property (nonatomic, retain) IBOutlet UITableView *table;

- (void)toggleEdit;

- (IBAction)addAccount:(id)sender;

- (void)openAccount:(LJAccount *)account animated:(BOOL)animated;

- (void)sendReport;

- (IBAction)showSettings;

@end
