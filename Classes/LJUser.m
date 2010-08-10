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
@synthesize group;

- (id)initWithUsername:(NSString *)name group:(NSMutableArray *)groupArray {
	if (self = [super init]) {
		username = [name retain];
		group = groupArray;
	}

	return self;
}

- (void)dealloc {
	[username release];
	[group release];
	
	[super dealloc];
}

@end
