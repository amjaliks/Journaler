//
//  LJAccountState.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 26.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import "AccountStateInfo.h"

#define kKeyOpenedScreen @"openedScreen"
#define kKeyFirstVisiblePost @"firstVisiblePost"
#define kKeyFirstVisiblePostScrollPosition @"firstVisiblePostScrollPosition"
#define kKeyOpenedPost @"openedPost"
#define kKeyLastVisiblePostIndex @"lastVisiblePostIndex"
#define kKeyNewPostSubject @"newPostSubject"
#define kKeyNewPostText @"newPostText"
#define kKeyNewPostJournal @"newPostJournal"
#define kKeyNewPostSecurity @"newPostSecurity"
#define kKeyNewPostSelectedFriendGroups @"newPostSelectedFriendGroups"
#define kKeyNewPostPicKeyword @"newPostPicKeyword"
#define kKeyNewPostTags @"newPostTags"
#define kKeyNewPostMood @"newPostMood"
#define kKeyNewPostMusic @"newPostMusic"
#define kKeyNewPostLocation @"newPostLocation"
#define kKeyNewPostPromote @"newPostPromote"

@implementation AccountStateInfo

@synthesize openedScreen;
@synthesize firstVisiblePost;
@synthesize firstVisiblePostScrollPosition;
@synthesize openedPost;
@synthesize lastVisiblePostIndex;
@synthesize newPostSubject;
@synthesize newPostText;
@synthesize newPostJournal;
@synthesize newPostSecurity;
@synthesize newPostSelectedFriendGroups;
@synthesize newPostPicKeyword;
@synthesize newPostTags;
@synthesize newPostMood;
@synthesize newPostMusic;
@synthesize newPostLocation;
@synthesize newPostPromote;

#pragma mark -
#pragma mark NSCoder metodes

- (id) init {
	self = [super init];
	if (self != nil) {
		newPostPromote = YES;
	}
	return self;
}

- (void) dealloc {
	[firstVisiblePost release];
	[openedPost release];
	[newPostSubject release];
	[newPostText release];
	[newPostSelectedFriendGroups release];
	[newPostPicKeyword release];
	[newPostTags release];
	[newPostMood release];
	[newPostLocation release];
	[super dealloc];
}


- (id)initWithCoder:(NSCoder *)coder {
	if (self = [self init]) {
		openedScreen = [coder decodeIntForKey:kKeyOpenedScreen];
		firstVisiblePost = [[coder decodeObjectForKey:kKeyFirstVisiblePost] retain];
		firstVisiblePostScrollPosition = [coder decodeIntegerForKey:kKeyFirstVisiblePostScrollPosition];
		openedPost = [[coder decodeObjectForKey:kKeyOpenedPost] retain];
		lastVisiblePostIndex = [coder decodeIntegerForKey:kKeyLastVisiblePostIndex];
		newPostSubject = [[coder decodeObjectForKey:kKeyNewPostSubject] retain];
		newPostText = [[coder decodeObjectForKey:kKeyNewPostText] retain];
		newPostSecurity = [coder decodeIntForKey:kKeyNewPostSecurity];
		newPostSelectedFriendGroups = [[coder decodeObjectForKey:kKeyNewPostSelectedFriendGroups] retain];
		newPostPicKeyword = [[coder decodeObjectForKey:kKeyNewPostPicKeyword] retain];
		newPostTags = [[coder decodeObjectForKey:kKeyNewPostTags] retain];
		newPostMood = [[coder decodeObjectForKey:kKeyNewPostMood] retain];
		newPostMusic = [[coder decodeObjectForKey:kKeyNewPostMusic] retain];
		newPostLocation = [[coder decodeObjectForKey:kKeyNewPostLocation] retain];
		newPostPromote = [coder decodeBoolForKey:kKeyNewPostPromote];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:openedScreen forKey:kKeyOpenedScreen];
	[coder encodeObject:firstVisiblePost forKey:kKeyFirstVisiblePost];
	[coder encodeInteger:firstVisiblePostScrollPosition forKey:kKeyFirstVisiblePostScrollPosition];
	[coder encodeObject:openedPost forKey:kKeyOpenedPost];
	[coder encodeInteger:lastVisiblePostIndex forKey:kKeyLastVisiblePostIndex];
	[coder encodeObject:newPostSubject forKey:kKeyNewPostSubject];
	[coder encodeObject:newPostText forKey:kKeyNewPostText];
	[coder encodeInt:newPostSecurity forKey:kKeyNewPostSecurity];
	[coder encodeObject:newPostSelectedFriendGroups forKey:kKeyNewPostSelectedFriendGroups];
	[coder encodeObject:newPostPicKeyword forKey:kKeyNewPostPicKeyword];
	[coder encodeObject:newPostTags forKey:kKeyNewPostTags];
	[coder encodeObject:newPostMood forKey:kKeyNewPostMood];
	[coder encodeObject:newPostMusic forKey:kKeyNewPostMusic];
	[coder encodeObject:newPostLocation forKey:kKeyNewPostLocation];
	[coder encodeBool:newPostPromote forKey:kKeyNewPostPromote];
}

@end
