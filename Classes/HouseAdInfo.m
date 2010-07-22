//
//  HouseAdInfo.m
//  Journaler
//
//  Created by Natālija Dudareva on 7/13/10.
//  Copyright 2010 A25. All rights reserved.
//

#import "HouseAdInfo.h"

#define kKeyNextShowDate @"nextShowDate"
#define kKeyNextServerCheckDate @"nextServerCheckDate"
#define kKeyBannerEndDate @"bannerEndDate"
#define kKeyBannerShowCount @"bannerShowCount"
#define kKeyAdIsLoaded @"adIsLoaded"

@implementation HouseAdInfo

@synthesize nextShowDate;
@synthesize nextServerCheckDate;
@synthesize bannerEndDate;
@synthesize bannerShowCount;
@synthesize adIsLoaded;

#pragma mark -
#pragma mark NSCoder metodes

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [self init]) {
		nextShowDate = [[coder decodeObjectForKey:kKeyNextShowDate] retain];
		nextServerCheckDate = [[coder decodeObjectForKey:kKeyNextServerCheckDate] retain];
		bannerEndDate = [[coder decodeObjectForKey:kKeyBannerEndDate] retain];
		bannerShowCount = [coder decodeIntegerForKey:kKeyBannerShowCount];
		adIsLoaded = [coder decodeBoolForKey:kKeyAdIsLoaded];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:nextShowDate forKey:kKeyNextShowDate];
	[coder encodeObject:nextServerCheckDate forKey:kKeyNextServerCheckDate];
	[coder encodeObject:bannerEndDate forKey:kKeyBannerEndDate];
	[coder encodeInteger:bannerShowCount forKey:kKeyBannerShowCount];
	[coder encodeBool:adIsLoaded forKey:kKeyAdIsLoaded];
}

- (void)dealloc {
	[nextShowDate release];
	[nextServerCheckDate release];
	[bannerEndDate release];
	
	[super dealloc];
}

@end
