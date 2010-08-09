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
@synthesize fullname;
@synthesize groupmask;

- (id)initWithUsername:(NSString *)name group:(NSUInteger)mask {
	if (self = [super init]) {
		username = [name retain];
		groupmask = mask;
	}

	return self;
}

- (void)dealloc {
	[username release];
	[fullname release];
	
	[super dealloc];
}

@end
