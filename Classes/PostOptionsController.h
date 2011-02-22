//
//  PostOptionsController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.30.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "LiveJournal.h"
#import "Common.h"
#import "AccountProvider.h"

@class LJAccount;
@protocol PostOptionsControllerDataSource;

@interface PostOptionsController : UITableViewController <AccountProvider> { //<CLLocationManagerDelegate, MKReverseGeocoderDelegate> {
	id<AccountProvider> accountProvider;
	
	// vērtības
	NSString *currentSong;
	MPMusicPlayerController *musicPlayer;
	
	BOOL locating;
	UIView *locateView;
	UIButton *locateMeButton;
	UIActivityIndicatorView *locateActivity;
//	CLLocationManager *locationManager;
	//CMGeocoder *geocoder;
	
	BOOL hidingKeyboard;
	BOOL viewWillDisappear;
	BOOL viewWillDisappearAnimated;
	
	id<PostOptionsControllerDataSource> dataSource;
}

@property (readonly) NSString *currentSong;

- (id)initWithAccountProvider:(id<AccountProvider>)accountProvider;
- (void)done;

- (void)tagsChanged:(id)sender;
- (void)moodChanged:(id)sender;
- (void)musicChanged:(id)sender;
- (void)locationChanged:(id)sender;
- (void)promoteChanged:(id)sender;

- (void)musicPlayerStateChanged:(id)sender;

//- (void)locateMePressed:(id)sender;
//- (void)revertLocateMeButton;
//- (void)releaseGeocoder;
//- (void)failedToLocate;

- (void)keyboardWillHide:(id)sender;
- (void)keyboardDidHide:(id)sender;

@end
