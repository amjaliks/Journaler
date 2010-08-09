//
//  BannerViewController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.23.
//  Copyright 2010 A25. All rights reserved.
//

#import "BannerViewController.h"
#import "SynthesizeSingleton.h"
#import "HAManager.h"


@implementation BannerViewController

- (void)setVisibleBanner:(UIView *)visibleBannerView animated:(BOOL)animated {
	if ([bannerView.subviews lastObject] != visibleBannerView) {
		if (visibleBannerView) {
			// ja nepieciešams animēt un baneris ir redzams, tad vispirms paslēpjam baneri
			[self hideBannerAnimated:animated];
		}
		
		// izņemam šobrīd rādāmo baneri no banera vietas		
		[[[bannerView subviews] lastObject] removeFromSuperview];
		
		if (visibleBannerView) {
			// ievietojam jauno baneri šajā vietā
			[bannerView addSubview:visibleBannerView];
			[self showBanner];
		}
	}
}

- (void)showBanner {
	if (!visible) {
		visible = YES;
		
		CGRect bannerFrame = bannerView.frame;
		CGRect viewFrame = resizeView.frame;
		
		viewFrame.size.height -= bannerFrame.size.height;
		bannerFrame.origin.y = viewFrame.size.height;
		
		[UIView beginAnimations:@"showAd" context:nil];
		bannerView.frame = bannerFrame;
		resizeView.frame = viewFrame;
		[UIView commitAnimations];
	}
}

- (void)hideBannerAnimated:(BOOL)animated {
	if (visible) {
		CGRect bannerFrame = bannerView.frame;
		CGRect viewFrame = resizeView.frame;
		
		viewFrame.size.height += bannerFrame.size.height;
		bannerFrame.origin.y = viewFrame.size.height;
		
		if (animated) {
			[UIView beginAnimations:@"hideAd" context:nil];
		}
		bannerView.frame = bannerFrame;
		resizeView.frame = viewFrame;
		if (animated) {
			[UIView commitAnimations];
		}
		
		visible = NO;
	}
}

- (void)addBannerToView:(UIView *)newSuperView resizeView:(UIView *)newResizeView {
	if (bannerView.superview != newSuperView) {	
		[self removeBannerFromView];
		
		superView = newSuperView;
		resizeView = newResizeView;
		
		CGRect bannerFrame = bannerView.frame;
		bannerFrame.origin.y = newResizeView.frame.size.height;
		bannerView.frame = bannerFrame;
		
		[newSuperView addSubview:bannerView];
		
		if ([bannerView.subviews count]) {
			[self showBanner];
		}
	}
}

- (void)removeBannerFromView {
	if ([bannerView superview]) {
		[self hideBannerAnimated:NO];
		[bannerView removeFromSuperview];
	}
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
	[self setVisibleBanner:iAdBannerView animated:YES];
#ifdef DEBUG
	NSLog(@"ad loaded: %5.0f", -([startDate timeIntervalSinceNow]));
#endif
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
	[self setVisibleBanner:[houseAdManager bannerView] animated:YES];
#ifdef DEBUG
	NSLog(@"ad failed: %5.0f", -([startDate timeIntervalSinceNow]));
#endif
}

#pragma mark -
#pragma mark singleton metodes

- (id)init {
	if (self = [super init]) {
		visible = NO;
		
		bannerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 50.0f)];
		
		iAdBannerView = [[ADBannerView alloc] init];
		if (iAdBannerView) {
			iAdBannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
			iAdBannerView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifier320x50];
			iAdBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
			iAdBannerView.delegate = self;
		}
#ifdef DEBUG
		startDate = [[NSDate alloc] init];
#endif
	}
	
	return self;
}

SYNTHESIZE_SINGLETON_FOR_CLASS(BannerViewController)

@end
