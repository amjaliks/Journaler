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

#define appDelegate ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate])
#define appWebViewController appDelegate.webViewController
#define APP_USER_PIC_CACHE appDelegate.userPicCache

@class ALReporter, WebViewController;

@class AccountsViewController;

@interface JournalerAppDelegate : NSObject <UIApplicationDelegate> {
    IBOutlet UIWindow *window;
	IBOutlet WebViewController *webViewController;

    IBOutlet UINavigationController *navigationController;
	IBOutlet AccountsViewController *accountsViewController;
	
	ALReporter *reporter;
}

@property (nonatomic, retain) ALReporter *reporter;
@property (readonly) WebViewController *webViewController;

@end

