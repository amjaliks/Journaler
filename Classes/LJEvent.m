//
//  LJNewEvent.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.24.
//  Copyright 2010 A25. All rights reserved.
//

#import "LJEvent.h"


@implementation LJEvent

@synthesize journal;
@synthesize journalType;
@synthesize poster;
@synthesize posterType;
@synthesize subject;
@synthesize event;
@synthesize security;
@synthesize selectedFriendGroups;
@synthesize picKeyword;
@synthesize tags;
@synthesize mood;
@synthesize music;
@synthesize location;
@synthesize datetime;
@synthesize replyCount;
@synthesize userPicUrl;
@synthesize ditemid;

- (void) dealloc {
	[journal release];
	[poster release];
	[subject release];
	[event release];
	[selectedFriendGroups release];
	[picKeyword release];
	[tags release];
	[mood release];
	[music release];
	[location release];

	[super dealloc];
}

+ (LJJournalType)journalTypeForKey:(NSString *)key {
	if ([@"P" isEqualToString:key]) {
		return LJJournalTypeJournal;
	} else if ([@"C" isEqualToString:key]) {
		return LJJournalTypeCommunity;
	} else if ([@"N" isEqualToString:key]) {
		return LJJournalTypeNews;
	}
	return LJJournalTypeCommunity;
}

+ (LJEventSecurityLevel)securityLevelForKey:(NSString *)key {
	if ([@"public" isEqualToString:key]) {
		return LJEventSecurityPublic;
	} else {
		return LJEventSecurityFriends;
	}
}

@end
