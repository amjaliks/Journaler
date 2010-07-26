//
//  StateInfo.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.23.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AccountStateInfo.h"

#define kStateInfoOpenedAccountIndexNone -1

@interface StateInfo : NSObject <NSCoding> {
	NSInteger openedAccountIndex;
	NSMutableDictionary *accountsStateInfo;
}

@property (nonatomic) NSInteger openedAccountIndex;

- (AccountStateInfo *)stateInfoForAccount:(LJAccount *)account;
- (void)removeStateInfoForAccount:(LJAccount *)account;

@end
