/*
 *  Common.h
 *  Journaler
 *
 *  Created by Aleksejs Mjaliks on 09.12.02.
 *  Copyright 2009 A25. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@class LJAccount;

@protocol SelectedAccountProvider<NSObject> 

- (LJAccount *)selectedAccount;

@end
