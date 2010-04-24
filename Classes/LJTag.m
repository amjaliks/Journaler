//
//  LJTag.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 24.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import "LJTag.h"

#define kKeyName @"name"

@implementation LJTag

@synthesize name;

- (id)initWithName:(NSString *)newName {
		if (self = [super init]) {
			newName = [newName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			if ([newName length]) {
				name = [newName retain];
			} else {
				name = nil;
			}
		}
		return self;
}

- (void) dealloc {
	[name release];
	
	[super dealloc];
}


- (BOOL)isEqual:(id)object {
	if (self == object) {
		return YES;
	}
	if ([object isKindOfClass:[LJTag class]]) {
		return NSOrderedSame == [name caseInsensitiveCompare:[object name]];
	}
	return NO;
}

- (NSComparisonResult)compare:(LJTag *)otherTag {
	return [name caseInsensitiveCompare:otherTag.name];
}

#pragma mark -
#pragma mark NSCoder metodes

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [self init]) {
		name = [[coder decodeObjectForKey:kKeyName] retain];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:name forKey:kKeyName];
}

@end
