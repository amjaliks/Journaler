//
//  BannerViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.23.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>

@interface BannerViewController : NSObject <ADBannerViewDelegate> {
	ADBannerView *bannerView;
	UIView *superView;
	UIView *resizeView;
	
	BOOL visible;
	
	NSDate *startDate;
}

+ (BannerViewController *)controller;

- (void)showBanner;
- (void)hideBannerAnimated:(BOOL)animated;

- (void)addBannerToView:(UIView *)superView resizeView:(UIView *)resizeView;
- (void)removeBannerFromView;

@end
