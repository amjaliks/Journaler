//
//  LJFriendGroup.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.21.
//  Copyright 2010 A25. All rights reserved.
//

#import "LJFriendGroup.h"


@implementation LJFriendGroup

@synthesize groupID;
@synthesize name;
@synthesize sortOrder;
@synthesize publicGroup;


- (id)initWithID:(NSUInteger)newGroupID name:(NSString *)newName sortOrder:(NSUInteger)newSortOrder publicGroup:(BOOL)newPublicGroup {
	if (self = [super init]) {
		groupID = newGroupID;
		name = [newName retain];
		sortOrder = newSortOrder;
		publicGroup = newPublicGroup;
	}
	return self;
}

- (void) dealloc {
	[name release];
	[super dealloc];
}


#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [self init]) {
		groupID = [coder decodeIntegerForKey:@"id"];
		name = [[coder decodeObjectForKey:@"name"] retain];
		sortOrder = [coder decodeIntegerForKey:@"sordOrder"];
		//publicGroup = [coder decodeBoolForKey:@"public"];
	}
	
	return self;
}


- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInteger:groupID forKey:@"id"];
	[coder encodeObject:name forKey:@"name"];
	[coder encodeInteger:sortOrder forKey:@"sortOrder"];
	[coder encodeBool:publicGroup forKey:@"public"];
}


@end
