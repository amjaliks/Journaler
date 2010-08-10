//
//  Filter.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.05.03.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LiveJournal.h"

typedef enum {
	FilterTypeAll,
	FilterTypeJournalType,
	FilterTypeGroup
} FilterType;

//typedef enum {
//	JournalTypeJournals,
//	JournalTypeCommunities,
//	JournalTypeSyndications
//} JournalType;

@interface FriendsPageFilter : NSObject<NSCoding> {
	FilterType filterType;
	LJJournalType journalType;
	NSString *group;
}

@property (nonatomic) FilterType filterType;
@property (nonatomic) LJJournalType journalType;
@property (nonatomic, retain) NSString *group;
@property (readonly) NSString *title;

- (NSArray *)filterPosts:(NSArray *)posts account:(LJAccount *)account;

@end
