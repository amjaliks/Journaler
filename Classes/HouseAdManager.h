//
//  HouseAdManager.h
//  Journaler
//
//  Created by Natālija Dudareva on 7/9/10.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HouseAdManager : NSObject {
	NSMutableDictionary *dataCache;
}

+ (HouseAdManager *)houseAdManager;

- (void)loadAd;

- (UIImage *) ensureFileAvailabilityFromURL:(NSString *)URL hash:(NSString *)hash;
- (NSData *) downloadDataFromURL:(NSString *)URL;


@end
