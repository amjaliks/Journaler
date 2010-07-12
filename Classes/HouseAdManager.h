//
//  HouseAdManager.h
//  Journaler
//
//  Created by Natālija Dudareva on 7/9/10.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HouseAdManager : NSObject {
	NSString *dataDirPath;
}

+ (HouseAdManager *)houseAdManager;

- (void)loadAd;

- (NSData *)readFile:(NSString *)fileName URL:(NSString *)URL;
- (NSData *) downloadDataFromURL:(NSString *)URL;


@end
