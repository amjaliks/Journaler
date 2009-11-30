//
//  PostOptionsController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.30.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	PostSecurityPublic,
	PostSecurityFriends,
	PostSecurityPrivate
} PostSecurityLevel;

@class LJAccount;
@protocol PostOptionsControllerDataSource;

@interface PostOptionsController : UITableViewController {
	// vērtības
	NSString *journal;
	PostSecurityLevel security;
	
	// tabulas šūnas
	UITableViewCell *journalCell;
	UITableViewCell *securityCell;
	UITableViewCell *promoteCell;
	
	id<PostOptionsControllerDataSource> dataSource;
}

@property (retain) id<PostOptionsControllerDataSource> dataSource;

- (void)done;

@end


@protocol PostOptionsControllerDataSource<NSObject> 

- (LJAccount *)selectedAccount;

@end