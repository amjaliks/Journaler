//
//  BannerViewController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.23.
//  Copyright 2010 A25. All rights reserved.
//

#import "BannerViewController.h"

BannerViewController *sharedInstance;

@implementation BannerViewController

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
		visible = NO;
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
	}
}

- (void)addBannerToView:(UIView *)newSuperView resizeView:(UIView *)newResizeView {
	[self removeBannerFromView];
	
	superView = newSuperView;
	resizeView = newResizeView;
	
	CGRect bannerFrame = bannerView.frame;
	bannerFrame.origin.y = newResizeView.frame.size.height;
	bannerView.frame = bannerFrame;
	
	[newSuperView addSubview:bannerView];
	
	if (bannerView.bannerLoaded) {
		[self showBanner];
	}
}

- (void)removeBannerFromView {
	if ([bannerView superview]) {
		if (bannerView.bannerLoaded) {
			[self hideBannerAnimated:NO];
		}
		[bannerView removeFromSuperview];
	}
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
	[self showBanner];
	NSLog(@"ad loaded: %5.0f", -([startDate timeIntervalSinceNow]));
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
	[self hideBannerAnimated:YES];
	NSLog(@"ad failed: %.0f", -([startDate timeIntervalSinceNow]));
}

#pragma mark -
#pragma mark singleton metodes

+ (BannerViewController *)controller {
	@synchronized (self) {
		if (sharedInstance == nil) {
			sharedInstance = [[super allocWithZone:nil] init];
		}
	}
	return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self controller] retain];
}

- (id)init {
	if (self = [super init]) {
		visible = NO;
		bannerView = [[ADBannerView alloc] init];
		if (bannerView) {
			bannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
			bannerView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifier320x50];
			bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
			bannerView.delegate = self;
		}
		startDate = [[NSDate alloc] init];
	}
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
