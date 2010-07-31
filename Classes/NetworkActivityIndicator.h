//
//  NetworkActivityIndicator.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.01.16.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#define networkActivityIndicator [NetworkActivityIndicator sharedNetworkActivityIndicator]

@interface NetworkActivityIndicator : NSObject {
	NSUInteger showCount;
}

+ (NetworkActivityIndicator *)sharedNetworkActivityIndicator;

- (void)show;
- (void)hide;

@end
