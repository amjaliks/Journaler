//
//  NSArrayAdditions.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 21.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import "NSArrayAdditions.h"


@implementation NSArray (NSArrayAdditions) 

- (BOOL)containsTag:(NSString *)tag {
	if ([self containsObject:tag]) {
		return YES;
	} else {
		BOOL found = NO;
		for (NSString *object in self) {
			if ([object caseInsensitiveCompare:tag] == NSOrderedSame) {
				found = YES;
				break;
			}
		}
		return found;
	}
}

@end


@implementation NSMutableArray (NSMutableArrayAdditions)

- (void)addTag:(NSString *)tag {
	if (![self containsTag:tag]) {
		[self addObject:tag];
	}
}

@end
