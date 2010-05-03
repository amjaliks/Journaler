//
//  LJFriendsPageController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.24.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LJAccount, FriendsPageFilter;

@interface FriendsPageController : UIViewController {
	// konts
	LJAccount *account;
	// filtrs
	FriendsPageFilter *friendsPageFilter;
	
	// 
	UIView *friendsPageView;
	
	// pogas
	UIBarButtonItem *refreshButtonItem;

	// stāvokļa josla
	IBOutlet UIView *statusLineView;
	IBOutlet UILabel *statusLineLabel;
	NSUInteger statusLineShowed;
}

#pragma mark Metodes

@property (readonly) FriendsPageFilter *friendsPageFilter;

// init
- (id)initWithAccount:(LJAccount *)account;
// pogas
- (void)refresh;
- (void)openFilter:(id)sender;
// stāvokļa josla
- (void) showStatusLine;
- (void) hideStatusLine;

@end
