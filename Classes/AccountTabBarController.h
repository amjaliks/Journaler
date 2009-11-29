//
//  AccountTabBarController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.20.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PostEditorController.h"

#ifdef LITEVERSION
	#import "AccountEditorController.h"
	#define LVP_ACCOUNT_EDITOR_CONTROLLER AccountEditorControllerDataSource, AccountEditorControllerDelegate,
#else
	#define LVP_ACCOUNT_EDITOR_CONTROLLER
#endif

@class LJAccount;

@interface AccountTabBarController : UITabBarController <LVP_ACCOUNT_EDITOR_CONTROLLER PostEditorControllerDataSource, UITabBarControllerDelegate> {
	LJAccount *account;
	
#ifdef LITEVERSION
	UIBarButtonItem *accountButton;
#endif
}

#ifdef LITEVERSION
@property (readonly) UIBarButtonItem *accountButton;
#endif

- (id) initWithAccount:(LJAccount *)account;
- (void) setViewControllersForAccount:(LJAccount *)account;

#ifdef LITEVERSION
- (void) editAccount;
#endif

@end
