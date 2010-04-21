//
//  LJAccount.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.22.
//  Copyright 2010 A25. All rights reserved.
//

#import "LJAccount.h"


@implementation LJAccount

@synthesize user;
@synthesize password;
@synthesize server;
@synthesize communities;
@synthesize friendGroups;
@synthesize tags;

@synthesize synchronized;
@synthesize tagsSynchronized;

- (id)init {
	if (self = [super init]) {
		synchronized = NO;
		tagsSynchronized = NO;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [self init]) {
		user = [[coder decodeObjectForKey:@"user"] retain];
		password = [[coder decodeObjectForKey:@"password"] retain];
		server = [[coder decodeObjectForKey:@"server"] retain];
		communities = [[coder decodeObjectForKey:@"communities"] retain];
		friendGroups = [[coder decodeObjectForKey:@"friendGroups"] retain];
		tags = [[coder decodeObjectForKey:@"tags"] retain];
		
		supportedFeatures = [LJAccount supportedFeaturesForServer:server];
		// ja serveris neatbalsta tagu sinhronizāciju, tad atzīmējam, ka tagi ir nosinhronizēti,
		// lai lietotne necenšas sinhronizēt tos
		tagsSynchronized = ![self supports:ServerFeatureMethodGetUserTags];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:1 forKey:@"version"];
	[coder encodeObject:user forKey:@"user"];
	[coder encodeObject:password forKey:@"password"];
	[coder encodeObject:server forKey:@"server"];
	[coder encodeObject:communities forKey:@"communities"];
	[coder encodeObject:friendGroups forKey:@"friendGroups"];
	[coder encodeObject:tags forKey:@"tags"];
}

- (NSString *)title {
	return [NSString stringWithFormat:@"%@@%@", user, server];
}

- (BOOL) isEqual:(id)anObject {
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

+ (ServerFeature)supportedFeaturesForServer:(NSString *)server {
	if ([@"livejournal.com" isEqualToString:server]) {
		return ServerFeatureAll;
	} else if ([@"klab.lv" isEqualToString:server]) {
		return ServerFeatureNone;
	} else if ([@"insanejournal.com" isEqualToString:server]) {
		return ServerFeatureAll;
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
