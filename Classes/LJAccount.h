//
//  LJAccount.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.22.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PostOptionsController.h"

enum {
	ServerFeatureNone = 0,
	ServerFeatureMethodGetUserTags = 1,
	ServerFeaturePostEventUserAgent = 1 << 1,
	
	ServerFeatureAll = ServerFeaturePostEventUserAgent | ServerFeatureMethodGetUserTags
} typedef ServerFeature;

@interface LJAccount : NSObject<NSCoding> {
	ServerFeature supportedFeatures;

	NSString *user;
	NSString *password;
	NSString *server;
	
	NSArray *communities;
	NSArray *friendGroups;
	NSArray *picKeywords;
	NSArray *tags;
	
	BOOL synchronized;
	BOOL tagsSynchronized;
}

@property (retain) NSString *user;
@property (retain) NSString *password;
@property (retain) NSString *server;
@property (retain) NSArray *communities;
@property (retain) NSArray *friendGroups;
@property (retain) NSArray *picKeywords;
@property (retain) NSArray *tags;

@property BOOL synchronized;
@property BOOL tagsSynchronized;

@property (readonly) NSString *title;

+ (ServerFeature)supportedFeaturesForServer:(NSString *)server;
- (BOOL)supports:(ServerFeature)feature;

@end
