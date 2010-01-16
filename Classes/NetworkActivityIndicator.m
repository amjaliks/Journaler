//
//  NetworkActivityIndicator.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.01.16.
//  Copyright 2010 A25. All rights reserved.
//

#import "NetworkActivityIndicator.h"

static NetworkActivityIndicator *sharedInstance;

@implementation NetworkActivityIndicator

- (void)show {
	@synchronized (self) {
		if (showCount == 0) {
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		}
		
		showCount++;
	}
}

- (void)hide {
	@synchronized (self) {
		showCount--;
		
		if (showCount == 0) {
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		}
	}
}

#pragma mark Singleton metodes

+ (NetworkActivityIndicator *)sharedInstance {
	@synchronized (self) {
		if (sharedInstance == nil) {
			sharedInstance = [[super allocWithZone:nil] init];
		}
	}
	return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedInstance] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
