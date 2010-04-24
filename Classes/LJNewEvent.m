//
//  LJNewEvent.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.24.
//  Copyright 2010 A25. All rights reserved.
//

#import "LJNewEvent.h"


@implementation LJNewEvent

@synthesize journal;
@synthesize subject;
@synthesize event;
@synthesize security;
@synthesize selectedFriendGroups;
@synthesize picKeyword;
@synthesize tags;
@synthesize mood;


- (void) dealloc {
	[journal release];
	[subject release];
	[event release];
	[selectedFriendGroups release];
	[picKeyword release];
	[tags release];
	[mood release];

	[super dealloc];
}


@end
