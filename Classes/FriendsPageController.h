//
//  LJFriendsPageController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.24.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef LITEVERSION
	#import "AdMobDelegateProtocol.h"
	#define ADMOBDELEGATE <AdMobDelegate>
	@class AdMobView;
#else
	#define ADMOBDELEGATE
#endif

@class LJAccount;

@interface FriendsPageController : UIViewController ADMOBDELEGATE {
	// konts
	LJAccount *account;
	
	// 
	UIView *friendsPageView;
	
	// pogas
	UIBarButtonItem *refreshButtonItem;

	// stāvokļa josla
	UIView *statusLineView;
	UILabel *statusLineLabel;
	NSUInteger statusLineShowed;
	
#ifdef LITEVERSION
	AdMobView *adMobView;
#endif
	
}

// stāvokļa josla
@property (nonatomic, retain) IBOutlet UIView *statusLineView;
@property (nonatomic, retain) IBOutlet UILabel *statusLineLabel;

#pragma mark Metodes

// init
- (id)initWithAccount:(LJAccount *)account;
// pogas
- (void)refresh;
// stāvokļa josla
- (void) showStatusLine;
- (void) hideStatusLine;

#ifdef LITEVERSION
// reklāma
- (void)initAdMobView;
#endif

@end
