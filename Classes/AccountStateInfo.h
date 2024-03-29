//
//  LJAccountState.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 26.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LiveJournal.h"

@class FriendsPageFilter;

typedef enum {
	OpenedScreenFriendsPage = 0,
	OpenedScreenPost = 1,
	OpenedScreenNewPost = 2
} OpenedScreenType;

@interface AccountStateInfo : NSObject <NSCoding> {
	// atvērtais ekrāns
	OpenedScreenType openedScreen;
	
	// draugu lapas stāvoklis
	NSString *firstVisiblePost;
	NSInteger firstVisiblePostScrollPosition;
	NSInteger lastVisiblePostIndex;

	// atvērtā raksta indekss
	NSInteger openedPostIndex;

	FriendsPageFilter *friendsPageFilter;
	
	NSString *newPostSubject;
	NSString *newPostText;
	NSString *newPostJournal;
	LJEventSecurityLevel newPostSecurity;
	NSArray *newPostSelectedFriendGroups;
	NSString *newPostPicKeyword;
	NSSet *newPostTags;
	NSString *newPostMood;
	NSString *newPostMusic;
	NSString *newPostLocation;
	BOOL newPostPromote;
}

// atvērtais ekrāns
@property OpenedScreenType openedScreen;

// draugu lapas stāvoklis
@property (retain, nonatomic) NSString *firstVisiblePost;
@property NSInteger firstVisiblePostScrollPosition;
@property NSInteger lastVisiblePostIndex;

// atvērtā raksta indekss
@property (nonatomic) NSInteger openedPostIndex;

@property (retain, nonatomic) FriendsPageFilter *friendsPageFilter;
@property (retain, nonatomic) NSString *newPostSubject;
@property (retain, nonatomic) NSString *newPostText;
@property (retain, nonatomic) NSString *newPostJournal;
@property LJEventSecurityLevel newPostSecurity;
@property (retain, nonatomic) NSArray *newPostSelectedFriendGroups;
@property (retain, nonatomic) NSString *newPostPicKeyword;
@property (retain, nonatomic) NSSet *newPostTags;
@property (retain, nonatomic) NSString *newPostMood;
@property (retain, nonatomic) NSString *newPostMusic;
@property (retain, nonatomic) NSString *newPostLocation;
@property BOOL newPostPromote;

@end
