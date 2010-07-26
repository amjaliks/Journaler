//
//  AccountsViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.01.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"
#import "AccountManager.h"

// kontu saraksta kontrolieris
@interface AccountsViewController : TableViewController {
	AccountManager *accountManager;
	
	IBOutlet UINavigationController *accountEditorNavigationController;
	IBOutlet UINavigationController *settingsNavigationController;
	IBOutlet UITabBarController *accountTabBarController;
	
	IBOutlet UIBarButtonItem *addButton;
	IBOutlet UIBarButtonItem *settingsButton;

	LJAccount *selectedAccount;
}

@property (readonly) AccountManager *accountManager;
@property (readonly) LJAccount *selectedAccount;

- (IBAction)addAccount:(id)sender;
- (IBAction)showSettings:(id)sender;

- (void)restoreState;

- (void)openAccountAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)didAddNewAccount;

@end
