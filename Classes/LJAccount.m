//
//  LJAccount.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.22.
//  Copyright 2010 A25. All rights reserved.
//

#import "LJAccount.h"

#define kKeyUser @"user"
#define kKeyPassword @"password"
#define kKeyServer @"server"
#define kKeyCommunities @"communities"
#define kKeyFriendGroups @"friendGroups"
#define kKeyFriends @"friends"
#define kKeyPicKeywords @"picKeywords"
#define kKeyTags @"tags"
#define kKeyMoods @"moods"
#define kKeyLastKnownMoodID @"lastKnownMoodID"

@implementation LJAccount

@synthesize user;
@synthesize password;
@synthesize server;
@synthesize communities;
@synthesize friendGroups;
@synthesize friends;
@synthesize picKeywords;
@synthesize tags;
@synthesize moods;

@synthesize synchronized;
@synthesize tagsSynchronized;
@synthesize loginSynchronized;

#pragma mark -
#pragma mark Atmiņas pārvaldīšana

- (id)init {
	if (self = [super init]) {
		synchronized = NO;
		tagsSynchronized = NO;
	}
	return self;
}

- (void) dealloc {
	[user release];
	[password release];
	[server release];
	[communities release];
	[friendGroups release];
	[friends release];
	[picKeywords release];
	[tags release];
	[moods release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark NSCoder metodes

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [self init]) {
		user = [[coder decodeObjectForKey:kKeyUser] retain];
		password = [[coder decodeObjectForKey:kKeyPassword] retain];
		self.server = [[coder decodeObjectForKey:kKeyServer] retain];
		communities = [[coder decodeObjectForKey:kKeyCommunities] retain];
		friendGroups = [[coder decodeObjectForKey:kKeyFriendGroups] retain];
		friends = [[coder decodeObjectForKey:kKeyFriends] retain];
		picKeywords = [[coder decodeObjectForKey:kKeyPicKeywords] retain];
		tags = [[coder decodeObjectForKey:kKeyTags] retain];
		moods = [[coder decodeObjectForKey:kKeyMoods] retain];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:user forKey:kKeyUser];
	[coder encodeObject:password forKey:kKeyPassword];
	[coder encodeObject:server forKey:kKeyServer];
	[coder encodeObject:communities forKey:kKeyCommunities];
	[coder encodeObject:friendGroups forKey:kKeyFriendGroups];
	[coder encodeObject:friends forKey:kKeyFriends];
	[coder encodeObject:picKeywords forKey:kKeyPicKeywords];
	[coder encodeObject:tags forKey:kKeyTags];
	[coder encodeObject:moods forKey:kKeyMoods];
}

#pragma mark -
#pragma mark NSObject metodes

- (BOOL)isEqual:(id)anObject {
	if (self == anObject) {
		return YES;
	}
	if (!anObject) {
		return NO;
	}
	if ([anObject isKindOfClass:[LJAccount class]]) {
		return [self.title isEqualToString:((LJAccount *) anObject).title];
	} else {
		return NO;
	}
}

- (NSUInteger)hash {
	return [self.title hash];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
	return [self retain];
}

#pragma mark -
#pragma mark Īpašības

- (NSString *)title {
	return [NSString stringWithFormat:@"%@@%@", user, server];
}

- (void)setServer:(NSString *)newServer {
	if (![server isEqual:newServer]) {
		[server release];
		server = [newServer retain];

		// pēc servera uzstāšīanas, nosakam savietojamo fīču sarakstu
		supportedFeatures = [LJAccount supportedFeaturesForServer:server];
		
		// ja serveris neatbalsta tagu sinhronizāciju, tad atzīmējam, ka tagi ir nosinhronizēti,
		// lai lietotne necenšas sinhronizēt tos
		tagsSynchronized = ![self supports:ServerFeatureMethodGetUserTags];
	}
	
}

#pragma mark -
#pragma mark Savietojamības ar serveriem

+ (ServerFeature)supportedFeaturesForServer:(NSString *)server {
	if ([@"livejournal.com" isEqualToString:server]) {
#ifndef LITEVERSION
		return ServerFeatureAll;
#else
		return ServerFeatureAll ^ ServerFeatureFriendsPageFilterByGroup;
#endif
	} else if ([@"klab.lv" isEqualToString:server]) {
		return ServerFeatureFriendsPageFilterByGroup;
	} else if ([@"insanejournal.com" isEqualToString:server]) {
		return ServerFeatureAll ^ ServerFeatureFriendsPageFilterByJournalType;
	} else {
#ifdef DEBUG
		return ServerFeatureAll;
#else
		return ServerFeatureNone;
#endif
	}
}

- (BOOL)supports:(ServerFeature)feature {
	return (feature & supportedFeatures) == feature;
}



@end
