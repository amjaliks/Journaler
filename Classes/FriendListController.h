//
//  FriendListController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.20.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef LITEVERSION
	#import "AdMobDelegateProtocol.h"
	#define ADMOBDELEGATE , AdMobDelegate
	@class AdMobView;
#else
	#define ADMOBDELEGATE
#endif

@class LJAccount, PostSummaryCell;

@interface FriendListController : UIViewController <UITableViewDataSource, UITableViewDelegate ADMOBDELEGATE> {
	// konts
	LJAccount *account;
	// ielasīti raksti
	NSMutableArray *loadedPosts;
	
	// tabula
	UITableView *tableView;
	PostSummaryCell *templateCell;
	
	// stāvokļa josla
	UIView *statusLineView;
	UILabel *statusLineLabel;
	CGRect frameForTableViewWithStatusLine;
	CGRect frameForTableViewWithOutStatusLine;
	
#ifdef LITEVERSION
	NSDate *lastRefresh;
	AdMobView *adMobView;
	NSTimer *adRefreshTimer;
#endif
}

#pragma mark Īpašības

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet PostSummaryCell *templateCell;

// stāvokļa josla
@property (nonatomic, retain) IBOutlet UIView *statusLineView;
@property (nonatomic, retain) IBOutlet UILabel *statusLineLabel;


#pragma mark Metodes

// init
- (id)initWithAccount:(LJAccount *)account;
// raksti
- (void) firstSync;
- (void) loadPostsFromCacheFromOffset:(NSUInteger)offset;
- (NSUInteger) loadPostsFromServerAfter:(NSDate *)lastSync skip:(NSUInteger)skip limit:(NSUInteger)limit;
- (void) addNewOrUpdateWithPosts:(NSArray *)events;
- (void) reloadTable;
- (void) preprocessPosts;
// stāvokļa josla
- (void) showStatusLine;
- (void) hideStatusLine;
- (void) updateStatusLineText:(NSString *)text;

@end
