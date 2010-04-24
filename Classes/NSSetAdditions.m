//
//  NSArrayAdditions.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 21.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import "NSSetAdditions.h"


@implementation NSSet (NSSetAdditions) 

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

- (NSArray *)sortedArray {
	NSArray *array;
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	array = [[self allObjects] sortedArrayUsingDescriptors:sortDescriptors];
	
	[sortDescriptors release];
	[sortDescriptor release];
	
	return [[array retain] autorelease];
}

@end


@implementation NSMutableSet (NSMutableSetAdditions)

- (void)addTag:(NSString *)tag {
	if (![self containsTag:tag]) {
		[self addObject:tag];
	}
}

- (void)addObjectsFromSet:(NSSet *)set {
	for (id object in set) {
		[self addObject:object];
	}
}

@end
