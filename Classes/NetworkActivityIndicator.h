//
//  NetworkActivityIndicator.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.01.16.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NetworkActivityIndicator : NSObject {
	NSUInteger showCount;
}

+ (NetworkActivityIndicator *)sharedInstance;

- (void)show;
- (void)hide;

@end
