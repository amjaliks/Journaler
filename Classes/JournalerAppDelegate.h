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
#import "ADManager.h"

#define APP_DELEGATE ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate])
#define APP_USER_PIC_CACHE APP_DELEGATE.userPicCache
#define APP_WEB_VIEW_CONTROLLER APP_DELEGATE.webViewController
#define APP_MODEL APP_DELEGATE.model

@class ALReporter, WebViewController;

@class AccountsViewController;

@interface JournalerAppDelegate : NSObject <UIApplicationDelegate> {

	Model *model;
	UserPicCache *userPicCache;
	
    UIWindow *window;
    UINavigationController *navigationController;
	AccountsViewController *accountsViewController;
	
	WebViewController *webViewController;
	
	ALReporter *reporter;
	
#ifdef LITEVERSION
	ADManager *adManager;
#endif
}

@property (nonatomic, retain) ALReporter *reporter;
@property (nonatomic, retain) Model *model;
@property (nonatomic, retain) UserPicCache *userPicCache;

@property (readonly) WebViewController *webViewController;

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

