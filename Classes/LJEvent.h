//
//  LJNewEvent.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.24.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	LJJournalTypeJournal,
	LJJournalTypeCommunity,
	LJJournalTypeSyndication,
	LJJournalTypeNews
} LJJournalType;

typedef enum {
	LJEventSecurityPublic,
	LJEventSecurityFriends,
	LJEventSecurityPrivate,
	LJEventSecurityCustom
} LJEventSecurityLevel;

@interface LJEvent : NSObject {
	NSString *journal;
	LJJournalType journalType;
	NSString *poster;
	LJJournalType posterType;
	NSString *subject;
	NSString *event;
	LJEventSecurityLevel security;
	NSArray *selectedFriendGroups;
	NSString *picKeyword;
	NSSet *tags;
	NSString *mood;
	NSString *music;
	NSString *location;
	NSDate *datetime;
	NSUInteger replyCount;
	NSString *userPicUrl;
	NSNumber *ditemid;
}

@property (nonatomic, retain) NSString *journal;
@property (nonatomic) LJJournalType journalType;
@property (nonatomic, retain) NSString *poster;
@property (nonatomic) LJJournalType posterType;
@property (nonatomic, retain) NSString *subject;
@property (nonatomic, retain) NSString *event;
@property (nonatomic) LJEventSecurityLevel security;
@property (nonatomic, retain) NSArray *selectedFriendGroups;
@property (nonatomic, retain) NSString *picKeyword;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSString *mood;
@property (nonatomic, retain) NSString *music;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSDate *datetime;
@property (nonatomic) NSUInteger replyCount;
@property (nonatomic, retain) NSString *userPicUrl;
@property (nonatomic, retain) NSNumber *ditemid;

+ (LJJournalType)journalTypeForKey:(NSString *)key;
+ (LJEventSecurityLevel)securityLevelForKey:(NSString *)key;

@end
