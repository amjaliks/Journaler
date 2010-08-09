//
//  HouseAdManager.h
//  Journaler
//
//  Created by Natālija Dudareva on 7/9/10.
//  Copyright 2010 A25. All rights reserved.
//

#import "HAInfo.h"
#import <Foundation/Foundation.h>

#define houseAdManager [HAManager sharedHAManager]

@interface HAManager : NSObject {
	NSString *dataDirPath;
	HAInfo *info;
	
	NSString *bannerPath;
	NSString *smallBannerPath;
	
	BOOL campaingActive;
	BOOL showAdOnStart;
	
	UIButton *bannerView;
	
	UIViewController *rootViewController;
}

@property (nonatomic, assign) UIViewController *rootViewController;
@property (readonly) BOOL showAdOnStart;

+ (HAManager *)sharedHAManager;

- (void)loadAd;
- (void)showAd;
- (void)prepareAd;
- (void)dismissAd;

- (void)loadInfo;
- (void)storeInfo;

- (BOOL)downloadDataFromURL:(NSString *)URL toPath:(NSString *)path;
- (NSData *)downloadDataFromURL:(NSString *)URL;

- (UIView *)bannerView;


@end
