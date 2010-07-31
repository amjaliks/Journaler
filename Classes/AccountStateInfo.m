//
//  LJAccountState.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 26.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import "AccountStateInfo.h"

#import "FriendsPageFilter.h"

#define kKeyOpenedScreen @"openedScreen"
#define kKeyFirstVisiblePost @"firstVisiblePost"
#define kKeyFirstVisiblePostScrollPosition @"firstVisiblePostScrollPosition"
#define kKeyOpenedPostIndex @"openedPostIndex"
#define kKeyLastVisiblePostIndex @"lastVisiblePostIndex"
#define kKeyFriendsPageFilter @"friendsPageFilter"
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
@synthesize lastVisiblePostIndex;

@synthesize openedPostIndex;

@synthesize friendsPageFilter;
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

- (id) init {
	self = [super init];
	if (self != nil) {
		newPostPromote = YES;
	}
	return self;
}

- (void) dealloc {
	[firstVisiblePost release];
	[friendsPageFilter release];
	[newPostSubject release];
	[newPostText release];
	[newPostSelectedFriendGroups release];
	[newPostPicKeyword release];
	[newPostTags release];
	[newPostMood release];
	[newPostLocation release];
	[super dealloc];
}


#pragma mark -
#pragma mark NSCoder metodes

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [self init]) {
		// atvērtais ekrāns
		openedScreen = [coder decodeIntForKey:kKeyOpenedScreen];
		
		firstVisiblePost = [[coder decodeObjectForKey:kKeyFirstVisiblePost] retain];
		firstVisiblePostScrollPosition = [coder decodeIntegerForKey:kKeyFirstVisiblePostScrollPosition];
		lastVisiblePostIndex = [coder decodeIntegerForKey:kKeyLastVisiblePostIndex];

		openedPostIndex = [coder decodeIntegerForKey:kKeyOpenedPostIndex];

		friendsPageFilter = [[coder decodeObjectForKey:kKeyFriendsPageFilter] retain];
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
	// atvērtais ekrāns
	[coder encodeInt:openedScreen forKey:kKeyOpenedScreen];
	
	[coder encodeObject:firstVisiblePost forKey:kKeyFirstVisiblePost];
	[coder encodeInteger:firstVisiblePostScrollPosition forKey:kKeyFirstVisiblePostScrollPosition];
	[coder encodeInteger:lastVisiblePostIndex forKey:kKeyLastVisiblePostIndex];

	[coder encodeInteger:openedPostIndex forKey:kKeyOpenedPostIndex];

	[coder encodeObject:friendsPageFilter forKey:kKeyFriendsPageFilter];
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

#pragma mark -
#pragma mark Īpašības

-(FriendsPageFilter *)friendsPageFilter {
	if (!friendsPageFilter) {
		friendsPageFilter = [[FriendsPageFilter alloc] init];
	}
	return friendsPageFilter;
}

@end
