//
//  Filter.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.05.03.
//  Copyright 2010 A25. All rights reserved.
//

#import "FriendsPageFilter.h"
#import "Model.h"
#import "LJUser.h"

#define kKeyFilterType @"filterType"
#define kKeyJournalType @"journalType"
#define kKeyGroup @"group"

@implementation FriendsPageFilter

@synthesize filterType;
@synthesize journalType;
@synthesize group;

- (id)init {
	self = [super init];
	if (self != nil) {
		filterType = FilterTypeAll;
	}
	return self;
}

- (id)copy {
	FriendsPageFilter *newFilter = [[FriendsPageFilter alloc] init];
	newFilter.filterType = self.filterType;
	newFilter.journalType = self.journalType;
	newFilter.group = [self.group copy];
	
	return newFilter;
}

- (BOOL)isEqual:(id)object {
	if (self == object) return YES;
	if (![object isKindOfClass:[self class]]) return NO;
	
	if (self.filterType != [object filterType]) return NO;
	if (self.filterType == FilterTypeAll) {
		return YES;
	} else if (self.filterType == FilterTypeJournalType) {
		return self.journalType == [object journalType];
	} else if (self.filterType == FilterTypeGroup) {
		return [self.group isEqualToString:[object group]];
	}
	
	return NO;
}
	
- (NSUInteger)hash {
	return [self.title hash];
}

#pragma mark -
#pragma mark NSCoding metodes

- (id)initWithCoder:(NSCoder *)decoder{
	if (self = [self init]) {
		filterType = [decoder decodeIntForKey:kKeyFilterType];
		if (filterType == FilterTypeJournalType) {
			journalType = [decoder decodeIntForKey:kKeyJournalType];
		} else if (filterType == FilterTypeGroup) {
			group = [[decoder decodeObjectForKey:kKeyGroup] retain];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:filterType forKey:kKeyFilterType];
	if (filterType == FilterTypeJournalType) {
		[coder encodeInt:journalType forKey:kKeyJournalType];
	} else if (filterType == FilterTypeGroup) {
		[coder encodeObject:group forKey:kKeyGroup];
	}
}


#pragma mark -
#pragma mark Atmiņa pārvadle

- (void) dealloc {
	[group release];
	[super dealloc];
}

#pragma mark -
#pragma mark Filtra metodes

// teksts, ko rādīt virsrakstā
- (NSString *)title {
	if (filterType == FilterTypeAll) {
		return NSLocalizedString(@"All", nil);
	} else if (filterType == FilterTypeJournalType) {
		if (journalType == LJJournalTypeJournal) {
			return NSLocalizedString(@"Journals", nil);
		} else if (journalType == LJJournalTypeCommunity) {
			return NSLocalizedString(@"Communities", nil);
		} else { // journalType == LJJournalTypeSyndication
			return NSLocalizedString(@"Syndicated feeds", nil);
		}
	} else if (filterType == FilterTypeGroup) {
		return group;
	}
	
	return nil;
}

// filtrē rakstu atbilstoši filtra uzstādījumiem
- (NSArray *)filterPosts:(NSArray *)posts account:(LJAccount *)account {
	if (filterType == FilterTypeAll) {
		// nekas nav jāfiltrē, atgriežam masīva kopiju
		return [[posts copy] autorelease];
	}
	
	NSMutableArray *filteredPosts = [[NSMutableArray alloc] init];
	
	if (filterType == FilterTypeJournalType) {
		// filtrējam pēc žurnāla veida
		for (Post* post in posts) {
			if ([post.journalType intValue] == journalType) {
				[filteredPosts addObject:post];
			}
		}
	} else if (filterType == FilterTypeGroup) {
		for (Post* post in posts) {
			for (LJUser *user in account.friends) {
				if ([post.poster isEqualToString: user.username] || [post.journal isEqualToString: user.username]) {
					for (LJFriendGroup *userGroup in user.group) {
						if ([group isEqualToString: userGroup.name]) {
							[filteredPosts addObject:post];
						}
					}
				}
			}
		}
	}
	
	return [filteredPosts autorelease];
}

@end
