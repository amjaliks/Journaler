//
//  LJUser.m
//  Journaler
//
//  Created by Natālija Dudareva on 8/9/10.
//  Copyright 2010 A25. All rights reserved.
//

#import "LJUser.h"


@implementation LJUser

@synthesize username;
@synthesize groups;

- (id)initWithUsername:(NSString *)name groups:(NSMutableArray *)groupArray {
	if (self = [super init]) {
		username = [name retain];
		groups = [groupArray copy];
	}

	return self;
}

- (void)dealloc {
	[username release];
	[groups release];
	
	[super dealloc];
}


#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [self init]) {
		username = [[coder decodeObjectForKey:@"username"] retain];
		groups = [[coder decodeObjectForKey:@"groups"] retain];
	}
	
	return self;
}


- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:username forKey:@"username"];
	[coder encodeObject:groups forKey:@"groups"];
}

@end
