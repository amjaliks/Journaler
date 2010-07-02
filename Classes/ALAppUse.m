//
//  ALAppUse.m
//  Appnlytics
//
//  Created by Aleksejs Mjaliks on 09.11.03.
//  Copyright 2009 A25. All rights reserved.
//

#import "ALAppUse.h"


@implementation ALAppUse

//@synthesize appVersion;
@synthesize date;

- (id)initWithCurrentDate {
	if (self = [super init]) {
		date = [[NSDate alloc] init];		
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super init]) {
		static NSString *key = @"date";
		date = [[coder decodeObjectForKey:key] copy];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	static NSString *key = @"date";
	[coder encodeObject:date forKey:key];
}

- (void) dealloc {
	[date release];
	[super dealloc];
}


@end
