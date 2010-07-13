//
//  AccountsViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.01.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"
#import "AccountEditorController.h"

// kontu saraksta kontrolieris
@interface AccountsViewController : TableViewController<AccountEditorControllerDataSource, AccountEditorControllerDelegate> {
	UINavigationController *editAccountViewController;
	UIViewController *accountViewController;
	
	NSMutableArray *accounts;
	LJAccount *selectedAccount;
	NSString *selectedAccountTitle;
		
	// kešs inicializēto kontrolierus glabāšanai
	NSMutableDictionary *cacheTabBarControllers;
	
	IBOutlet UIBarButtonItem *settingsButton;
}

@property (nonatomic, retain) IBOutlet UIViewController *editAccountViewController;
@property (nonatomic, retain) IBOutlet UIViewController *accountViewController;

- (IBAction)addAccount:(id)sender;

- (void)openAccount:(LJAccount *)account animated:(BOOL)animated;

- (void)sendReport;

- (IBAction)showSettings;

@end
