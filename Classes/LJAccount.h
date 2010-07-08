//
//  LJAccount.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.22.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	ServerFeatureNone = 0,
	ServerFeatureMethodGetUserTags = 1,
	ServerFeaturePostEventUserAgent = 1 << 1,
	ServerFeatureFriendsPageFilterByJournalType = 1 << 2,
	ServerFeatureFriendsPageFilterByGroup = 1 << 3,
	
	ServerFeatureAll = ServerFeaturePostEventUserAgent 
			| ServerFeatureMethodGetUserTags 
			| ServerFeatureFriendsPageFilterByJournalType
			| ServerFeatureFriendsPageFilterByGroup
} typedef ServerFeature;

@interface LJAccount : NSObject<NSCoding> {
	ServerFeature supportedFeatures;

	NSString *user;
	NSString *password;
	NSString *server;
	
	NSString *title;
	
	NSArray *communities;
	NSArray *friendGroups;
	NSArray *picKeywords;
	NSSet *tags;
	NSSet *moods;
	
	BOOL synchronized;
	BOOL tagsSynchronized;
	BOOL loginSynchronized;
}

@property (retain) NSString *user;
@property (retain) NSString *password;
@property (retain) NSString *server;
@property (retain) NSArray *communities;
@property (retain) NSArray *friendGroups;
@property (retain) NSArray *picKeywords;
@property (retain) NSSet *tags;
@property (retain) NSSet *moods;

@property BOOL synchronized;
@property BOOL tagsSynchronized;
@property BOOL loginSynchronized;

@property (readonly) NSString *title;

+ (ServerFeature)supportedFeaturesForServer:(NSString *)server;
- (BOOL)supports:(ServerFeature)feature;

@end
