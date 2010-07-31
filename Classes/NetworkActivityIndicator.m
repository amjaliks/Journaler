//
//  NetworkActivityIndicator.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.01.16.
//  Copyright 2010 A25. All rights reserved.
//

#import "NetworkActivityIndicator.h"
#import "SynthesizeSingleton.h"


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

SYNTHESIZE_SINGLETON_FOR_CLASS(NetworkActivityIndicator)

@end
