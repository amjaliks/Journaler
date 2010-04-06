//
//  LJFriendsPageController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.24.
//  Copyright 2009 A25. All rights reserved.
//

#import "FriendsPageController.h"

#import "JournalerAppDelegate.h"
#import "LiveJournal.h"
#import "AccountManager.h"


//#ifdef LITEVERSION
//// Lite versijā ir reklāma
//#import "AdMobView.h"
//#endif

@implementation FriendsPageController

- (id)initWithAccount:(LJAccount *)aAccount {
    if (self = [super initWithNibName:@"FriendsPageController" bundle:nil]) {
		account = [aAccount retain];
		
		// cilnes bildīte
		UIImage *image = [UIImage imageNamed:@"friends.png"];
		UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Friends" image:image tag:0];
		self.tabBarItem = tabBarItem;
		[tabBarItem release];

    	refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
		self.navigationItem.rightBarButtonItem = refreshButtonItem;
	}
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// stāvokļa josla
	statusLineView.frame = CGRectMake(0, self.view.frame.size.height - 24, self.view.frame.size.width, 24);
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[AccountManager sharedManager] setUnsignedIntegerValue:OpenedScreenFriendsPage forAccount:account.title forKey:kStateInfoOpenedScreenType];
	
//#ifdef LITEVERSION
//	[self refreshAdMobView];
//#endif
	statusLineView.frame = CGRectMake(0, self.view.frame.size.height - 24, self.view.frame.size.width, 24);
}

#ifndef LITEVERSION
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIDeviceOrientationPortrait || UIDeviceOrientationIsLandscape(interfaceOrientation);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	// stāvokļa josla
	statusLineView.frame = CGRectMake(0, self.view.frame.size.height - 24, self.view.frame.size.width, 24);
}
#endif


#pragma mark Pogas

- (void)refresh {}

#pragma mark Stāvokļa josla

// parāda stāvokļa joslu
- (void) showStatusLine {
	@synchronized (statusLineView) {
		if (!statusLineShowed) {
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			[self.view addSubview:statusLineView];
			
			[pool release];
		}
		statusLineShowed++;
	}
}

// paslēpj stāvokļa joslu
- (void) hideStatusLine {
	@synchronized (statusLineView) {
		statusLineShowed--;
		if (!statusLineShowed) {
			[statusLineView removeFromSuperview];
		}
	}
}


//#ifdef LITEVERSION

//#pragma mark Reklāma
//
//- (void)initAdMobView {
//	adMobView = [AdMobView requestAdWithDelegate:self];
//	[adMobView retain];
//	adMobLastRefresh = [[NSDate alloc] init];
//}
//
//- (void)refreshAdMobView {
//	NSTimeInterval interval = [adMobLastRefresh timeIntervalSinceNow];
//	if (interval <= -30.0f) {
//		[adMobView requestFreshAd];
//		[adMobLastRefresh release];
//		adMobLastRefresh = [[NSDate alloc] init];
//	}
//}
//
//- (NSString *)publisherId {
//	return @"a14ae77c080ab49"; // this should be prefilled; if not, get it from www.admob.com
//}
//
//- (UIColor *)adBackgroundColor {
//	return [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
//}
//
//- (UIColor *)primaryTextColor {
//	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
//}
//
//- (UIColor *)secondaryTextColor {
//	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
//}
//
//- (BOOL)mayAskForLocation {
//	return NO;
//}
//
//- (void)didReceiveAd:(AdMobView *)adView {
//	CGRect frame = friendsPageView.frame;
//	frame.origin.y += 48;
//	frame.size.height -= 48;
//	friendsPageView.frame = frame;
//	
//	[self.view addSubview:adView];
//}
//
//- (void)didFailToReceiveAd:(AdMobView *)adView {
//	[adMobView release];
//}
//
//// To receive test ads rather than real ads...
//#ifdef DEBUG
//- (BOOL)useTestAd {
//	return YES;
//}
//
//- (NSString *)testAdAction {
//	return @"url"; // see AdMobDelegateProtocol.h for a listing of valid values here
//}
//#endif
//
//- (NSString *)keywords {
//	return @"livejournal friends"; 
//}
//
//
//#endif

- (void)dealloc {
//#ifdef LITEVERSION
//	// ar reklāmām saistītie resursi
////	[adMobView release];
//	[adMobLastRefresh release];
//#endif
	[account release];
	[super dealloc];
}


@end
