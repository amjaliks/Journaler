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
#import "AccountProvider.h"
#import "AccountTabBarController.h"

@class AccountTabBarController;

// kontu saraksta kontrolieris
@interface AccountsViewController : TableViewController <AccountProvider> {
	IBOutlet UINavigationController *accountEditorNavigationController;
	IBOutlet UINavigationController *settingsNavigationController;
	IBOutlet AccountTabBarController *accountTabBarController;
	
	IBOutlet UIBarButtonItem *addButton;
	IBOutlet UIBarButtonItem *settingsButton;
	IBOutlet UIBarButtonItem *backButtonItem;

	LJAccount *account;
	AccountStateInfo *accountStateInfo;
}

@property (nonatomic, assign) LJAccount *account;

- (IBAction)addAccount:(id)sender;
- (IBAction)showSettings:(id)sender;

- (void)restoreState;

- (void)openAccountAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)didAddNewAccount;

@end
