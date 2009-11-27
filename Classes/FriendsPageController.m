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


#ifdef LITEVERSION
// Lite versijā ir reklāma
#import "AdMobView.h"
#endif

@implementation FriendsPageController

// stāvokļa josla
@synthesize statusLineView;
@synthesize statusLineLabel;

- (id)initWithAccount:(LJAccount *)aAccount {
    if (self = [super initWithNibName:@"FriendsPageController" bundle:nil]) {
		account = aAccount;
		
		// cilnes bildīte
		UIImage *image = [UIImage imageNamed:@"friends.png"];
		UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Friends" image:image tag:0];
		self.tabBarItem = tabBarItem;
		[tabBarItem release];
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// pieliekam pogas
	refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
	self.parentViewController.navigationItem.rightBarButtonItem = refreshButtonItem;

	// stāvokļa josla
	statusLineView.frame = CGRectMake(0, self.view.frame.size.height - 24, 320, 24);
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
//	
//	// pieliekam pogas
//	if (refreshButtonItem) 
//	refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
//	self.parentViewController.navigationItem.rightBarButtonItem = refreshButtonItem;
	
}

#pragma mark Pogas

- (void)refresh {}

#pragma mark Stāvokļa josla

// parāda stāvokļa joslu
- (void) showStatusLine {
	@synchronized (statusLineView) {
		if (!statusLineShowed) {
			[self.view addSubview:statusLineView];
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


#ifdef LITEVERSION

#pragma mark Reklāma

- (void)initAdMobView {
	adMobView = [AdMobView requestAdWithDelegate:self];
	[adMobView retain];
}

- (NSString *)publisherId {
	return @"a14ae77c080ab49"; // this should be prefilled; if not, get it from www.admob.com
}

- (UIColor *)adBackgroundColor {
	return [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
}

- (UIColor *)primaryTextColor {
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
}

- (UIColor *)secondaryTextColor {
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
}

- (BOOL)mayAskForLocation {
	return NO;
}

- (void)didReceiveAd:(AdMobView *)adView {
	CGRect frame = friendsPageView.frame;
	frame.origin.y += 48;
	frame.size.height -= 48;
	friendsPageView.frame = frame;
	
	[self.view addSubview:adView];
}

- (void)didFailToReceiveAd:(AdMobView *)adView {
	[adMobView release];
}

// To receive test ads rather than real ads...
#ifdef DEBUG
- (BOOL)useTestAd {
	return YES;
}

- (NSString *)testAdAction {
	return @"url"; // see AdMobDelegateProtocol.h for a listing of valid values here
}
#endif

#endif

- (void)dealloc {
#ifdef LITEVERSION
	// ar reklāmām saistītie resursi
	[adMobView release];
#endif
	
	[super dealloc];
}


@end
