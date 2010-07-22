//
//  HouseAdManager.h
//  Journaler
//
//  Created by Natālija Dudareva on 7/9/10.
//  Copyright 2010 A25. All rights reserved.
//

#import "HouseAdInfo.h"
#import <Foundation/Foundation.h>

@interface HouseAdManager : NSObject {
	NSString *dataDirPath;
	HouseAdInfo *houseAdInfo;
	
	UIImage *image;
}

+ (HouseAdManager *)houseAdManager;

- (void)loadAd;
- (void)showAd:(UINavigationController *)navigationController;
- (BOOL)prepareAd;
- (void)dismissAd;

- (void)loadHouseAdInfo;
- (void)storeHouseAdInfo;

- (NSData *)readFile:(NSString *)fileName URL:(NSString *)URL;
- (NSData *)downloadDataFromURL:(NSString *)URL;


@end
