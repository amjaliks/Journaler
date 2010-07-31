//
//  AccountProvider.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.26.
//  Copyright 2010 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AccountManager.h"

@protocol AccountProvider

@required
@property (nonatomic, readonly) LJAccount *account;
@property (nonatomic, readonly) AccountStateInfo *accountStateInfo;

@end
