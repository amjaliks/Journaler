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

@interface FriendsPageController : UIViewController {
	// konts
	LJAccount *account;
	// filtrs
	FriendsPageFilter *friendsPageFilter;
	
	// 
	UIView *friendsPageView;
	FriendsPageTitleView *titleView;
	
	// pogas
	UIBarButtonItem *refreshButtonItem;
	IBOutlet UIActivityIndicatorView *spinnerView;
	IBOutlet UIBarButtonItem *spinnerItem;
	NSUInteger spinnerVisible;

	// stāvokļa josla
	IBOutlet UIView *statusLineView;
	IBOutlet UILabel *statusLineLabel;
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
