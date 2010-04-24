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
	NSString *picKeyword;
	NSSet *tags;
	NSString *mood;
	
	BOOL hidingKeyboard;
	BOOL viewWillDisappear;
	BOOL viewWillDisappearAnimated;
	
	id<PostOptionsControllerDataSource> dataSource;
}

@property (retain) id<PostOptionsControllerDataSource> dataSource;

@property (readonly) LJAccount *account;

@property (retain) NSString *journal;
@property PostSecurityLevel security;
@property (readonly) NSMutableArray *selectedFriendGroups;
@property (retain, nonatomic) NSSet *tags;
@property (retain, nonatomic) NSString *mood;
@property (retain) NSString *picKeyword;
@property (readonly) BOOL promote;

- (id)initWithAccount:(LJAccount *)account;
- (void)done;

- (void)tagsChanged:(id)sender;
- (void)moodChanged:(id)sender;
- (void)promoteChanged:(id)sender;

- (void)keyboardWillHide:(id)sender;
- (void)keyboardDidHide:(id)sender;

@end


@protocol PostOptionsControllerDataSource<NSObject> 

- (LJAccount *)selectedAccount;

@end