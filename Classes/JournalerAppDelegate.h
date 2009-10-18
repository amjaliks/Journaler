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

@interface JournalerAppDelegate : NSObject <UIApplicationDelegate> {

	Model *model;
	UserPicCache *userPicCache;

    UIWindow *window;
    UINavigationController *navigationController;
	
}

@property (nonatomic, retain) Model *model;
@property (nonatomic, retain) UserPicCache *userPicCache;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

