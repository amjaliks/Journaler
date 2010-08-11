//
//  BannerViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.23.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>

#define bannerViewController [HABannerViewController sharedHABannerViewController]

@interface HABannerViewController : NSObject <ADBannerViewDelegate> {
	ADBannerView *iAdBannerView;
	
	// vieta (laukums), kurā attēlot baneri
	UIView *bannerView;
	
	// pazīme, ka baneris ir redzams
	BOOL visible;
	
	UIView *superView;
	UIView *resizeView;
	
#ifdef DEBUG
	NSDate *startDate;
#endif
}

+ (HABannerViewController *)sharedHABannerViewController;

- (void)setVisibleBanner:(UIView *)visibleBannerView animated:(BOOL)animated;

- (void)showBanner;
- (void)hideBannerAnimated:(BOOL)animated;

- (void)addBannerToView:(UIView *)superView resizeView:(UIView *)resizeView;
- (void)removeBannerFromView;

@end
