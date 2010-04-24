//
//  LJMood.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 23.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import "LJMood.h"

#define kKeyID @"ID"
#define kKeyMood @"mood"

@implementation LJMood

@synthesize ID;
@synthesize mood;

#pragma mark -
#pragma mark Atmiņas pārvaldīšana

- (id)initWithID:(NSInteger)newID mood:(NSString *)newMood {
	if (self = [super init]) {
		ID = newID;
		mood = [newMood retain];
		
		hash = [[mood lowercaseString] hash];
	}
	return self;
}

- (id)initWithMood:(NSString *)newMood {
	return [self initWithID:0 mood:newMood];
}

- (void) dealloc {
	[mood release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoder metodes

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [self init]) {
		ID = [coder decodeIntegerForKey:kKeyID];
		mood = [[coder decodeObjectForKey:kKeyMood] retain];
		
		hash = [[mood lowercaseString] hash];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInteger:ID forKey:kKeyID];
	[coder encodeObject:mood forKey:kKeyMood];
}

#pragma mark -
#pragma mark NSObject metodes

- (BOOL)isEqual:(id)object {
	if (!mood) {
		return NO;
	}
	if (self == object) {
		return YES;
	}
	if (object == nil) {
		return NO;
	}
	if ([object isKindOfClass:[LJMood class]]) {
		if (ID && ID == [object ID]) {
			return YES;
		}
		object = [object mood];
	}
	if ([object isKindOfClass:[NSString class]]) {
		return [mood caseInsensitiveCompare:object] == NSOrderedSame;
	}
	return NO;
}

- (NSComparisonResult)compare:(LJMood *)otherMood {
	return [mood caseInsensitiveCompare:[otherMood mood]];
}

- (NSUInteger)hash {
	return hash;
}

@end
