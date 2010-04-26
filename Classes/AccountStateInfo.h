//
//  LJAccountState.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 26.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PostOptionsController.h"

typedef enum {
	OpenedScreenFriendsPage = 0,
	OpenedScreenPost = 1,
	OpenedScreenNewPost = 2
} OpenedScreenType;

@interface AccountStateInfo : NSObject<NSCoding> {
	OpenedScreenType openedScreen;
	NSString *firstVisiblePost;
	NSInteger firstVisiblePostScrollPosition;
	NSString *openedPost;
	NSInteger lastVisiblePostIndex;
	NSString *newPostSubject;
	NSString *newPostText;
	NSString *newPostJournal;
	PostSecurityLevel newPostSecurity;
	NSArray *newPostSelectedFriendGroups;
	NSString *newPostPicKeyword;
	NSSet *newPostTags;
	NSString *newPostMood;
	BOOL newPostPromote;
}

@property OpenedScreenType openedScreen;
@property (retain, nonatomic) NSString *firstVisiblePost;
@property NSInteger firstVisiblePostScrollPosition;
@property (retain, nonatomic) NSString *openedPost;
@property NSInteger lastVisiblePostIndex;
@property (retain, nonatomic) NSString *newPostSubject;
@property (retain, nonatomic) NSString *newPostText;
@property (retain, nonatomic) NSString *newPostJournal;
@property PostSecurityLevel newPostSecurity;
@property (retain, nonatomic) NSArray *newPostSelectedFriendGroups;
@property (retain, nonatomic) NSString *newPostPicKeyword;
@property (retain, nonatomic) NSSet *newPostTags;
@property (retain, nonatomic) NSString *newPostMood;
@property BOOL newPostPromote;

@end
