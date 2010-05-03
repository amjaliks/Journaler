//
//  Filter.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.05.03.
//  Copyright 2010 A25. All rights reserved.
//

#import "FriendsPageFilter.h"

#define kKeyFilterType @"filterType"
#define kKeyJournalType @"journalType"
#define kKeyGroup @"group"

@implementation FriendsPageFilter

@synthesize filterType;
@synthesize journalType;
@synthesize group;

- (id) init {
	self = [super init];
	if (self != nil) {
		filterType = FilterTypeAll;
	}
	return self;
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


@end
