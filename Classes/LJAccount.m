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

@synthesize text;
@synthesize subject;
@synthesize journal;
@synthesize security;
@synthesize promote;

@synthesize selectedTab;

@synthesize synchronized;

- (id)init {
	if (self = [super init]) {
		promote = YES;
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
		
		text = [[coder decodeObjectForKey:@"postText"] retain];
		subject = [[coder decodeObjectForKey:@"postSubject"] retain];
		journal = [[coder decodeObjectForKey:@"postJournal"] retain];
		security = [coder decodeIntegerForKey:@"postSecurity"];
		promote = [coder decodeBoolForKey:@"postPromote"];
		
		selectedTab = [coder decodeIntegerForKey:@"selectedTab"];
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
	
	[coder encodeObject:text forKey:@"postText"];
	[coder encodeObject:subject forKey:@"postSubject"];
	[coder encodeObject:journal forKey:@"postJournal"];
	[coder encodeInteger:security forKey:@"postSecurity"];
	[coder encodeBool:promote forKey:@"postPromote"];
	
	[coder encodeInteger:selectedTab forKey:@"selectedTab"];
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

@end
