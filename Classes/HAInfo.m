//
//  HouseAdInfo.m
//  Journaler
//
//  Created by Natālija Dudareva on 7/13/10.
//  Copyright 2010 A25. All rights reserved.
//

#import "HAInfo.h"

#define kKeyNextShowDate @"nextShowDate"
#define kKeyNextServerCheckDate @"nextServerCheckDate"
#define kKeyBannerEndDate @"bannerEndDate"
#define kKeyBannerShowCount @"bannerShowCount"
#define kKeyAdIsLoaded @"adIsLoaded"
#define kKeyTargetURL @"targetURL"
#define kKeySmallBannerLoaded @"smallBannerLoaded"

@implementation HAInfo

@synthesize nextShowDate;
@synthesize nextServerCheckDate;
@synthesize bannerEndDate;
@synthesize bannerShowCount;
@synthesize targetURL;
@synthesize adIsLoaded;
@synthesize smallBannerLoaded;

#pragma mark -
#pragma mark NSCoder metodes

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [self init]) {
		nextShowDate = [[coder decodeObjectForKey:kKeyNextShowDate] retain];
		nextServerCheckDate = [[coder decodeObjectForKey:kKeyNextServerCheckDate] retain];
		bannerEndDate = [[coder decodeObjectForKey:kKeyBannerEndDate] retain];
		bannerShowCount = [coder decodeIntegerForKey:kKeyBannerShowCount];
		targetURL = [[coder decodeObjectForKey:kKeyTargetURL] retain];
		adIsLoaded = [coder decodeBoolForKey:kKeyAdIsLoaded];
		smallBannerLoaded = [coder decodeBoolForKey:kKeySmallBannerLoaded];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:nextShowDate forKey:kKeyNextShowDate];
	[coder encodeObject:nextServerCheckDate forKey:kKeyNextServerCheckDate];
	[coder encodeObject:bannerEndDate forKey:kKeyBannerEndDate];
	[coder encodeInteger:bannerShowCount forKey:kKeyBannerShowCount];
	[coder encodeObject:targetURL forKey:kKeyTargetURL];
	[coder encodeBool:adIsLoaded forKey:kKeyAdIsLoaded];
	[coder encodeBool:smallBannerLoaded forKey:kKeySmallBannerLoaded];
}

- (void)dealloc {
	[nextShowDate release];
	[nextServerCheckDate release];
	[bannerEndDate release];
	[targetURL release];
	
	[super dealloc];
}

@end
