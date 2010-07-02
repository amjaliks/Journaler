//
//  ALProperty.m
//  Appnlytics
//
//  Created by Aleksejs Mjaliks on 09.11.16.
//  Copyright 2009 A25. All rights reserved.
//

#import "ALProperty.h"


@implementation ALProperty

@synthesize name;
@synthesize value;
@synthesize isSet;

- (id) initWithName:(NSString *)name_ value:(id)value_ {
	self = [super init];
	if (self != nil) {
		name = [name_ copy];
		if ([value_ isKindOfClass:[NSSet class]]) {
			if ([value_ count] > 1) {
				isSet = YES;
			} else if ([value_ count] == 1) {
				value_ = [value_ anyObject];
				isSet = NO;
			} else {
				value_ = nil;
			}
		} else {
			isSet = NO;
		}
		value = [value_ copy];
	}
	return self;
}

- (BOOL)isValueChanged:(ALProperty *)sentProperty {
	if (isSet != sentProperty.isSet) {
		return YES;
	}
	if (isSet) {
		return ![self.stringSet isEqualToSet:sentProperty.stringSet];
	} else {
		return ![self.stringValue isEqualToString:sentProperty.stringValue];
	}
}

- (NSString *)stringValue {
	if (!value || isSet) {
		return nil;
	}
	
	if (!stringValue) {
		if ([value isKindOfClass:[NSString class]]) {
			stringValue = [value retain];
		} else {
			stringValue = [[value stringValue] copy];
		}
	}
	return stringValue;
}

- (NSSet *)stringSet {
	if (!value || !isSet) {
		return nil;
	}
	
	if (!stringSet) {
		NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:[value count]];
		for (id object in value) {
			if ([object isKindOfClass:[NSString class]]) {
				[set addObject:object];
			} else {
				[set addObject:[object stringValue]];
			}
		}
		stringSet = set;
	}
	return stringSet;
}

- (void) dealloc {
	[name release];
	[value release];
	[stringValue release];
	[stringSet release];
	
	[super dealloc];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder {
	NSString * decodedName = [coder decodeObjectForKey:@"name"];
	id decodedValue = [coder decodeObjectForKey:@"value"];

	self = [self initWithName:decodedName value:decodedValue];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:value forKey:@"value"];
}


@end
