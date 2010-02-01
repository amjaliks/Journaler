//
//  JournalerAppDelegate.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.01.
//  Copyright A25 2009. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Model.h"
#import "UserPicCache.h"

#define APP_DELEGATE ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate])
#define APP_USER_PIC_CACHE APP_DELEGATE.userPicCache
#define APP_WEB_VIEW_CONTROLLER APP_DELEGATE.webViewController
#define APP_MODEL APP_DELEGATE.model

@class ALReporter, WebViewController;

#ifndef LITEVERSION
@class AccountsViewController;
#else
@class LJAccount;
#endif

@interface JournalerAppDelegate : NSObject <UIApplicationDelegate> {

	Model *model;
	UserPicCache *userPicCache;
	
    UIWindow *window;
    UINavigationController *navigationController;
#ifndef LITEVERSION
	AccountsViewController *rootViewController;
#else
	UIViewController *rootViewController;
#endif
	
	WebViewController *webViewController;
	
	ALReporter *reporter;
}

@property (nonatomic, retain) ALReporter *reporter;
@property (nonatomic, retain) Model *model;
@property (nonatomic, retain) UserPicCache *userPicCache;

@property (readonly) WebViewController *webViewController;

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

