//
//  Filter.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.05.03.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	FilterTypeAll,
	FilterTypeJournalType,
	FilterTypeGroup
} FilterType;

typedef enum {
	JournalTypeJournals,
	JournalTypeCommunities,
	JournalTypeSyndications
} JournalType;

@interface FriendsPageFilter : NSObject<NSCoding> {
	FilterType filterType;
	JournalType journalType;
	NSString *group;
}

@property (nonatomic) FilterType filterType;
@property (nonatomic) JournalType journalType;
@property (nonatomic, retain) NSString *group;
@property (readonly) NSString *title;

@end
