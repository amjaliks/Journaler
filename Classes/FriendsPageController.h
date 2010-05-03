//
//  LJFriendsPageController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.24.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LJAccount;

@interface FriendsPageController : UIViewController {
	// konts
	LJAccount *account;
	
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

// init
- (id)initWithAccount:(LJAccount *)account;
// pogas
- (void)refresh;
// stāvokļa josla
- (void) showStatusLine;
- (void) hideStatusLine;

@end
