//
//  PostOptionsController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.30.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Common.h"

typedef enum {
	PostSecurityPublic,
	PostSecurityFriends,
	PostSecurityPrivate,
	PostSecurityCustom
} PostSecurityLevel;

@class LJAccount;
@protocol PostOptionsControllerDataSource;

@interface PostOptionsController : UITableViewController {
	LJAccount *account;
	
	// vērtības
	BOOL promote;
	NSString *journal;
	PostSecurityLevel security;
	NSMutableArray *selectedFriendGroups;
	
	// tabulas šūnas
	UITableViewCell *journalCell;
	UITableViewCell *securityCell;
	UITableViewCell *promoteCell;
	UISwitch *promoteSwitch;
	
	id<PostOptionsControllerDataSource> dataSource;
}

@property (retain) id<PostOptionsControllerDataSource> dataSource;

@property (readonly) LJAccount *account;

@property (retain) NSString *journal;
@property PostSecurityLevel security;
@property (readonly) NSMutableArray *selectedFriendGroups;
@property (readonly) BOOL promote;

- (id)initWithAccount:(LJAccount *)account;
- (void)done;

- (void)promoteChanged;

@end


@protocol PostOptionsControllerDataSource<NSObject> 

- (LJAccount *)selectedAccount;

@end