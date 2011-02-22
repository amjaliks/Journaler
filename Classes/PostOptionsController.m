//
//  PostOptionsController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.30.
//  Copyright 2009 A25. All rights reserved.
//

#import "PostOptionsController.h"

#import "Macros.h"
#import "LiveJournal.h"
#import "PostJournalController.h"
#import "PostSecurityController.h"
#import "AccountManager.h"
#import "TextFieldCellView.h"
#import "TagListController.h"
#import "MoodListController.h"
#import "PicKeywordListController.h"
#import "UIViewAdditions.h"
#import "ErrorHandler.h"

// šūnu veidi
enum {
	SimpleCell,
	TextFieldCell,
	SwitchCell
};

// šūnu veidu ID
NSString *cellIds[] = { 
	@"SimpleCell",
	@"TextFieldCell",
	@"SwitchCell"
};

// skatu tagi
enum {
	SwitchTag = 1
};

// sekcijas
enum {
	SectionBasic, // raksta pamatdati
	SectionAdditional, // papildus dati par rakstu
	SectionPromote // promote
	
};

// pamatdati
enum {
	SectionBasicRowJournal,
	SectionBasicRowSecurity
};

enum {
	SectionAdditionalRowPicture,
	SectionAdditionalRowTags,
	SectionAdditionalRowMood,
	SectionAdditionalRowMusic,
	SectionAdditionalRowLocation
};

enum {
	SecrionPromoteRowPromote
};

@interface PostOptionsController ()

@property (readonly) id<AccountProvider> accountProvider;

@end


@implementation PostOptionsController

@synthesize accountProvider;
@synthesize currentSong;

- (id)initWithAccountProvider:(id<AccountProvider>)newAccountProvider {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
		accountProvider = newAccountProvider;
		
#ifndef LITEVERSION
    	// iPod notikumi
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
		[notificationCenter addObserver:self selector:@selector(musicPlayerStateChanged:) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:musicPlayer];
		[notificationCenter addObserver:self selector:@selector(musicPlayerStateChanged:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:musicPlayer];
		[musicPlayer beginGeneratingPlaybackNotifications];
		[self musicPlayerStateChanged:musicPlayer];
#endif
	}
	
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedString(@"Options", nil);

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.leftBarButtonItem = doneButton;
	[doneButton release];
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];	 
	// tastatūras notikumi
	[notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
	hidingKeyboard = NO;
	viewWillDisappear = NO;
	
	locateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 39, 39)];
	
//	locationManager = [[CLLocationManager alloc] init];
//	if (locationManager.locationServicesEnabled) {
//		locationManager.delegate = self;
//		locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
//		
//		locateMeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
//		[locateMeButton setImage:[UIImage imageNamed:@"locateme.png"] forState:UIControlStateNormal];
//		[locateMeButton setImage:[UIImage imageNamed:@"locateme-hover.png"] forState:UIControlStateHighlighted];
//		[locateMeButton setFrame:CGRectMake(0, 0, 39, 39)];
//		[locateMeButton addTarget:self action:@selector(locateMePressed:) forControlEvents:UIControlEventTouchUpInside];
//		
//		[locateView addSubview:locateMeButton];
//		
//		locateActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//		locateActivity.frame = CGRectMake(8, 8, 20, 20);
//		[locateActivity startAnimating];
//	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
	
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.view findAndResignFirstResonder];
	
	if (hidingKeyboard) {
		viewWillDisappear = YES;
		viewWillDisappearAnimated = animated;
	} else {
		[super viewWillDisappear:animated];	
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

#ifndef LITEVERSION
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIDeviceOrientationPortrait || UIDeviceOrientationIsLandscape(interfaceOrientation);
}
#endif

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[locateMeButton release];
	[locateActivity release];
	[locateView release];
//	[locationManager release];
//	locationManager = nil;
	
	self.navigationItem.leftBarButtonItem = nil;
}


- (void)done {
	if (locating) {
//		[locationManager stopUpdatingLocation];
//		[self releaseGeocoder];
//		[self revertLocateMeButton];
	}
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#ifndef LITEVERSION
    return 3;
#else
	return 2;
#endif
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) return 2;
	if (section == 1) return 5;
	return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// nosak šūnas veidu
	NSUInteger cellKind;
	if (indexPath.section == SectionBasic) {
		if (indexPath.row == SectionBasicRowJournal) { cellKind = SimpleCell; }
		else if (indexPath.row == SectionBasicRowSecurity) { cellKind = SimpleCell; };
	} else if (indexPath.section == SectionAdditional) {
		if (indexPath.row == SectionAdditionalRowPicture) { cellKind = SimpleCell; }
		else if (indexPath.row == SectionAdditionalRowTags) { cellKind = TextFieldCell; }
		else if (indexPath.row == SectionAdditionalRowMood) { cellKind = TextFieldCell; }
		else if (indexPath.row == SectionAdditionalRowMusic) { cellKind = TextFieldCell; }
		else if (indexPath.row == SectionAdditionalRowLocation) { cellKind = TextFieldCell; };
	} else if (indexPath.section == SectionPromote) {
		if (indexPath.row == 0) { cellKind = SwitchCell; };
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIds[cellKind]];
	
	if (!cell) {
		// ja nav atrasta piemērota šūna, izveidojam tādu
		if (cellKind == SimpleCell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIds[SimpleCell]];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		} else if (cellKind == TextFieldCell) {
			cell = [[TextFieldCellView alloc] initWithReuseIdentifier:cellIds[TextFieldCell]];
		} else if (cellKind == SwitchCell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIds[SwitchCell]];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UISwitch *cellSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(206, 9, 94, 26)];
			cellSwitch.tag = SwitchTag;
			cellSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
			[cell addSubview:cellSwitch];
			
			[cellSwitch release];
		}
	}
    
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			cell.textLabel.text = NSLocalizedString(@"Journal", nil);
			cell.detailTextLabel.text = self.accountStateInfo.newPostJournal;
		} else if (indexPath.row == 1) {
			cell.textLabel.text = NSLocalizedString(@"Security", nil);
			if (self.accountStateInfo.newPostSecurity == LJEventSecurityPublic) {
				cell.detailTextLabel.text = NSLocalizedString(@"Public", nil);
			} else if (self.accountStateInfo.newPostSecurity == LJEventSecurityFriends) {
				cell.detailTextLabel.text = NSLocalizedString(@"Friends only", nil);
			} else if (self.accountStateInfo.newPostSecurity == LJEventSecurityPrivate) {
				cell.detailTextLabel.text = NSLocalizedString(@"Private", nil);
			} else {
				cell.detailTextLabel.text = NSLocalizedString(@"Custom", nil);
			}
		}
	} else if (indexPath.section == SectionAdditional) {
		if (indexPath.row == SectionAdditionalRowPicture) {
			cell.textLabel.text = NSLocalizedString(@"Userpic", nil);
            NSString *picKeyword = self.accountStateInfo.newPostPicKeyword;
			cell.detailTextLabel.text = picKeyword ? picKeyword : NSLocalizedString(@"Default", nil);
		} else if (indexPath.row == SectionAdditionalRowTags) {
			cell.textLabel.text = NSLocalizedString(@"Tags", nil);
#ifndef LITEVERSION
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			((TextFieldCellView *)cell).text.placeholder = NSLocalizedString(@"separated by commas", nil);
#endif
			[(TextFieldCellView *)cell setTags:self.accountStateInfo.newPostTags];
			[(TextFieldCellView *)cell setTarget:self action:@selector(tagsChanged:)];
		} else if (indexPath.row == SectionAdditionalRowMood) {
			cell.textLabel.text = NSLocalizedString(@"Mood", nil);
#ifndef LITEVERSION
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			((TextFieldCellView *)cell).text.placeholder = NSLocalizedString(@"select from list or type here", nil);
#endif
			((TextFieldCellView *)cell).text.text = self.accountStateInfo.newPostMood;
			[(TextFieldCellView *)cell setTarget:self action:@selector(moodChanged:)];
		} else if (indexPath.row == SectionAdditionalRowMusic) {
			cell.textLabel.text = NSLocalizedString(@"Music", nil);
			cell.accessoryType = UITableViewCellAccessoryNone;
			((TextFieldCellView *)cell).text.text = self.accountStateInfo.newPostMusic;
			((TextFieldCellView *)cell).text.placeholder = currentSong;
			[(TextFieldCellView *)cell setTarget:self action:@selector(musicChanged:)];
		} else if (indexPath.row == SectionAdditionalRowLocation) {
			cell.textLabel.text = NSLocalizedString(@"Location", nil);
			cell.accessoryType = UITableViewCellAccessoryNone;
			//cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			//cell.accessoryView = locateView;
			((TextFieldCellView *)cell).text.text = self.accountStateInfo.newPostLocation;
			((TextFieldCellView *)cell).text.placeholder = nil;
			[(TextFieldCellView *)cell setTarget:self action:@selector(locationChanged:)];
		}
	} else if (indexPath.section == SectionPromote) {
		cell.textLabel.text = NSLocalizedString(@"Promote Journaler", nil);
		UISwitch *cellSwitch = (UISwitch *)[cell viewWithTag:SwitchTag];
		cellSwitch.on = self.accountStateInfo.newPostPromote;
		
		[cellSwitch removeTarget:self action:nil forControlEvents:UIControlEventValueChanged];
		[cellSwitch addTarget:self action:@selector(promoteChanged:) forControlEvents:UIControlEventValueChanged];
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionBasic) {
		if (indexPath.row == SectionBasicRowJournal) {
			PostJournalController *postJournalController = [[PostJournalController alloc] initWithPostOptionsController:self];
			[self.navigationController pushViewController:postJournalController animated:YES];
			[postJournalController release];
		} else { 
			PostSecurityController *postSecurityController = [[PostSecurityController alloc] initWithPostOptionsController:self];
			[self.navigationController pushViewController:postSecurityController animated:YES];
			[postSecurityController release];
		}
	} else if (indexPath.section == SectionAdditional) {
		if (indexPath.row == SectionAdditionalRowPicture) {
			PicKeywordListController *picKeywordListController = [[PicKeywordListController alloc] initWithPostOptionsController:self];
			[self.navigationController pushViewController:picKeywordListController animated:YES];
			[picKeywordListController release];
		}
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == SectionAdditional && indexPath.row == SectionAdditionalRowTags) {
		UIViewController *controller = [[TagListController alloc] initWithPostOptionsController:self];
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];	
	} else	if (indexPath.section == SectionAdditional && indexPath.row == SectionAdditionalRowMood) {
		UIViewController *controller = [[MoodListController alloc] initWithPostOptionsController:self];
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];	
	}
	
}

- (void)dealloc {
#ifndef LITEVERSION
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	// iPod notikumi
	[notificationCenter removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:musicPlayer];
	[notificationCenter removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:musicPlayer];
	[musicPlayer endGeneratingPlaybackNotifications]; 
#endif
	[super dealloc];
}

- (void)tagsChanged:(id)sender {
	self.accountStateInfo.newPostTags = ((TextFieldCellView *)sender).tags;
}

- (void)moodChanged:(id)sender {
	self.accountStateInfo.newPostMood = ((TextFieldCellView *)sender).text.text;
}

- (void)musicChanged:(id)sender {
	self.accountStateInfo.newPostMusic = ((TextFieldCellView *)sender).text.text;
}

- (void)locationChanged:(id)sender {
	self.accountStateInfo.newPostLocation = ((TextFieldCellView *)sender).text.text;
}

- (void)promoteChanged:(id)sender {
	self.accountStateInfo.newPostPromote = ((UISwitch *)sender).on;
}

- (void)setPicKeyword:(NSString *)newPicKeyword {
    self.accountStateInfo.newPostPicKeyword = newPicKeyword;
}

- (void)setTags:(NSSet *)newTags {
    self.accountStateInfo.newPostTags = newTags;
}

- (void)setMood:(NSString *)newMood {
    self.accountStateInfo.newPostMood = newMood;
}

- (void)setMusic:(NSString *)newMusic {
    self.accountStateInfo.newPostMusic = newMusic;
}

- (void)setLocation:(NSString *)newLocation {
	self.accountStateInfo.newPostLocation = newLocation;
}

#pragma mark -
#pragma mark Music Player

- (void)musicPlayerStateChanged:(id)sender {
	[currentSong autorelease];
	currentSong = nil;
	
	if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
		MPMediaItem *mediaItem = musicPlayer.nowPlayingItem;
		if ([[mediaItem valueForProperty:MPMediaItemPropertyMediaType] intValue] == MPMediaTypeMusic) {
			NSString *title = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
			NSString *artist = [mediaItem valueForProperty:MPMediaItemPropertyArtist];
			
			if (title && artist) {
				currentSong = [NSString stringWithFormat:@"%@ - %@", artist, title];
			} else if (title) {
				currentSong = title;
			} else if (artist) {
				currentSong = artist;
			}
			
			[currentSong retain];
		}
	}
	
	TextFieldCellView *cell = (TextFieldCellView *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SectionAdditionalRowMusic inSection:SectionAdditional]];
	cell.text.placeholder = currentSong;
}

#pragma mark -
#pragma mark Location

//- (void)locateMePressed:(id)sender {
//	locating = YES;
//	[locateMeButton removeFromSuperview];
//	[locateView addSubview:locateActivity];
//
//	//[self revertLocateMeButton];
//	[locationManager startUpdatingLocation];
//}
//
//- (void)revertLocateMeButton {
//	locating = NO;
//	[locateActivity removeFromSuperview];
//	[locateView addSubview:locateMeButton];
//}
//
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//	if (abs([[newLocation timestamp] timeIntervalSinceNow]) <= 60.0f) {
//		[manager stopUpdatingLocation];
//		
//		//geocoder = [[CMGeocoder alloc] initWithAPIKey:@"0b6884abe4ab4a3bab551d08b232fdad" coordinate:newLocation.coordinate];
//		//geocoder.delegate = self;
//		//[geocoder start];
//		[self revertLocateMeButton];
//	}
//}
//
//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//	if ([error code] == kCLErrorDenied) {
//		[locationManager stopUpdatingLocation];
//		[self failedToLocate];
//	}
//}
//
//- (void)reverseGeocoder:(MKReverseGeocoder *)sender didFindPlacemark:(MKPlacemark *)placemark {
//	[self releaseGeocoder];
//	NSString *currentLocation = [NSString string];
//	if (placemark.subLocality) {
//		currentLocation = placemark.subLocality;
//	}
//	if (placemark.locality) {
//		if ([currentLocation length]) {
//			currentLocation = [currentLocation stringByAppendingString:@", "];
//		}
//		currentLocation = [currentLocation stringByAppendingString:placemark.locality];
//	}
//	if (placemark.subAdministrativeArea) {
//		if ([currentLocation length]) {
//			currentLocation = [currentLocation stringByAppendingString:@", "];
//		}
//		currentLocation = [currentLocation stringByAppendingString:placemark.subAdministrativeArea];
//	}
//	if (placemark.administrativeArea) {
//		if ([currentLocation length]) {
//			currentLocation = [currentLocation stringByAppendingString:@", "];
//		}
//		currentLocation = [currentLocation stringByAppendingString:placemark.administrativeArea];
//	}
//	if (placemark.country) {
//		if ([currentLocation length]) {
//			currentLocation = [currentLocation stringByAppendingString:@", "];
//		}
//		currentLocation = [currentLocation stringByAppendingString:placemark.country];
//	}
//	
//	TextFieldCellView *cell = (TextFieldCellView *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SectionAdditionalRowLocation inSection:SectionAdditional]];
//	cell.text.text = currentLocation;
//	self.location = currentLocation;
//	
//	//[self revertLocateMeButton];
//}
//
//- (void)reverseGeocoder:(MKReverseGeocoder *)sender didFailWithError:(NSError *)error {
//	[self releaseGeocoder];
//	[self failedToLocate];
//}
//
//- (void)failedToLocate {
//	[self revertLocateMeButton];
//	showErrorMessage(NSLocalizedString(@"Location error", nil), NSLocalizedString(@"Failed to locate current position!", nil));
//}
//
//- (void)releaseGeocoder {
//	//[geocoder cancel];
//	//[geocoder release];
//	//geocoder = nil;
//}

#pragma mark -
#pragma mark Keyboard

- (void)keyboardWillHide:(id)sender {
	hidingKeyboard = YES;
}

- (void)keyboardDidHide:(id)sender {
	hidingKeyboard = NO;

	if (viewWillDisappear) {
		viewWillDisappear = NO;
		[super viewWillAppear:viewWillDisappearAnimated];
	}
}

#pragma mark -
#pragma mark Account Provider

- (LJAccount *)account {
    return self.accountProvider.account;
}

- (AccountStateInfo *)accountStateInfo {
    return  self.accountProvider.accountStateInfo;
}

@end

