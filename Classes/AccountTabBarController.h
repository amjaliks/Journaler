//
//  AccountTabBarController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.20.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@class LJAccount;

@interface AccountTabBarController : UITabBarController {
	LJAccount *account;
}

- (id) initWithAccount:(LJAccount *)account;

@end
