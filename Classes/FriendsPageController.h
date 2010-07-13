//
//  LJFriendsPageController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.24.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FriendsPageFilter.h"

@class LJAccount, FriendsPageTitleView;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
#import <iAd/iAd.h>
#define PROCOTOLS <ADBannerViewDelegate>
#endif

@interface FriendsPageController : UIViewController PROCOTOLS {
	// konts
	LJAccount *account;
	// filtrs
	FriendsPageFilter *friendsPageFilter;
	
	// 
	UIView *friendsPageView;
	FriendsPageTitleView *titleView;
	
	// pogas
	UIBarButtonItem *refreshButtonItem;

	// stāvokļa josla
	IBOutlet UIView *statusLineView;
	IBOutlet UILabel *statusLineLabel;
	NSUInteger statusLineShowed;
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	ADBannerView *bannerView;
	BOOL showingBanner;
#endif
}

#pragma mark Metodes

@property (readonly) LJAccount *account;
@property (readonly) FriendsPageFilter *friendsPageFilter;

// init
- (id)initWithAccount:(LJAccount *)account;
// pogas
- (void)refresh;
- (void)openFilter:(id)sender;
// stāvokļa josla
- (void)showStatusLine;
- (void)hideStatusLine;

- (void)filterFriendsPage;

@end
