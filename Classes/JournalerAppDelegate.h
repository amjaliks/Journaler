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

#ifdef LITEVERSION
@class LJAccount;
#endif

@interface JournalerAppDelegate : NSObject <UIApplicationDelegate> {

	Model *model;
	UserPicCache *userPicCache;
	
#ifndef LITEVERSION
	NSMutableArray *accounts;
#endif

    UIWindow *window;
    UINavigationController *navigationController;
	
	WebViewController *webViewController;
	
	ALReporter *reporter;
}

@property (nonatomic, retain) ALReporter *reporter;
@property (nonatomic, retain) Model *model;
@property (nonatomic, retain) UserPicCache *userPicCache;

@property (readonly) WebViewController *webViewController;

@property (nonatomic, retain) IBOutlet UIWindow *window;

#ifndef LITEVERSION
- (void) saveAccounts;
- (void) saveAccounts:(NSArray *)accounts;
- (NSArray *) loadAccounts;
#else
- (void) saveAccount:(LJAccount *)account;
- (LJAccount *) loadAccount;
#endif
@end

