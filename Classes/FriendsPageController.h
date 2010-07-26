//
//  LJFriendsPageController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.24.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FriendsPageFilter.h"
#import "AccountProvider.h"

@class LJAccount, FriendsPageTitleView;

@interface FriendsPageController : UIViewController <AccountProvider> {
	id<AccountProvider> accountProvider;
	LJAccount *previousAccount;
	
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
}

#pragma mark Metodes

@property (nonatomic, assign) id<AccountProvider> accountProvider;
@property (readonly) UIView *mainView;
@property (readonly) FriendsPageFilter *friendsPageFilter;

// aktivitātes indikators
- (void)showActivityIndicator;
- (void)hideActivityIndicator;
// pogas
- (void)refresh;
- (void)openFilter:(id)sender;

- (void)filterFriendsPage;

@end
