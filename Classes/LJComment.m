//
//  LJComment.m
//  Journaler
//
//  Created by Natālija Dudareva on 7/7/10.
//  Copyright 2010 A25. All rights reserved.
//

#import "LJComment.h"


@implementation LJComment

@synthesize commentBody;
@synthesize journal;
@synthesize ditemid;

- (void)dealloc {
	[commentBody release];
	[journal release];
	[ditemid release];
	
	[super dealloc];
}

@end
