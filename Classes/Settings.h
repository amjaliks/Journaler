//
//  SettingsManager.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.01.18.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kSettingsRefreshOnStart @"refresh_on_start"
#define kSettingsStartUpScreen @"start_up_screen"

#define kStartUpScreenAccountList @"account_list"
#define kStartUpScreenFriendsPage @"friends_page"
#define kStartUpScreenLastView @"last_view"

void registerUserDefaults();
