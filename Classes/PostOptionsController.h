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

@class LJAccount;
@protocol PostOptionsControllerDataSource;

@interface PostOptionsController : UITableViewController { //<CLLocationManagerDelegate, MKReverseGeocoderDelegate> {
	LJAccount *account;
	
	// vērtības
	BOOL promote;
	NSString *journal;
	LJEventSecurityLevel security;
	NSMutableArray *selectedFriendGroups;
	NSString *picKeyword;
	NSSet *tags;
	NSString *mood;
	NSString *music;
	NSString *location;
	
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

@property (retain) id<PostOptionsControllerDataSource> dataSource;

@property (readonly) LJAccount *account;

@property (retain, nonatomic) NSString *journal;
@property LJEventSecurityLevel security;
@property (readonly) NSMutableArray *selectedFriendGroups;
@property (retain, nonatomic) NSSet *tags;
@property (retain, nonatomic) NSString *mood;
@property (retain, nonatomic) NSString *picKeyword;
@property (retain, nonatomic) NSString *music;
@property (retain, nonatomic) NSString *location;
@property (readonly) BOOL promote;

@property (readonly) NSString *currentSong;

- (id)initWithAccount:(LJAccount *)account;
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


@protocol PostOptionsControllerDataSource<NSObject> 

- (LJAccount *)selectedAccount;

@end