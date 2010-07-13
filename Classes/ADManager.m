//
//  ADManager.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.13.
//  Copyright 2010 A25. All rights reserved.
//

#import "ADManager.h"
#import "TableViewController.h"

@implementation ADManager

- (id)initWithNavigationController:(UINavigationController *)newNavigationController {
	if (self = [super init]) {
		navigationController = newNavigationController;
		[self createAdView];
	}
	return self;
}

- (void)createAdView {
	// savietojamība ar 3.0
	Class ADBannerViewClass = NSClassFromString(@"ADBannerView");
	if (ADBannerViewClass) {
		bannerView = [[ADBannerViewClass alloc] initWithFrame:CGRectZero];
		[bannerView setRequiredContentSizeIdentifiers:[NSSet setWithObject:ADBannerContentSizeIdentifier320x50]];
		[bannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifier320x50];
		[bannerView setDelegate:self];
	}
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
	TableViewController *viewController = (TableViewController *)[navigationController visibleViewController];
	
	CGRect tableViewFrame = viewController.tableView.frame;
	tableViewFrame.size.height -= banner.frame.size.height;
	viewController.tableView.frame = tableViewFrame;
	
	CGRect bannerFrame = banner.frame;
	bannerFrame.origin.y = viewController.tableView.frame.size.height;
	banner.frame = bannerFrame;
	
	[viewController.view addSubview:banner];
}

@end
