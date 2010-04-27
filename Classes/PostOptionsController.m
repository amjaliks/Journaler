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
#ifdef BETA
	SectionAdditional, // papildus dati par rakstu
#endif
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
	SectionAdditionalRowMusic
};

enum {
	SecrionPromoteRowPromote
};

@implementation PostOptionsController

@synthesize account;
@synthesize dataSource;
@synthesize journal;
@synthesize security;
@synthesize selectedFriendGroups;
@synthesize picKeyword;
@synthesize tags;
@synthesize mood;
@synthesize music;
@synthesize promote;

@synthesize currentSong;

- (id)initWithAccount:(LJAccount *)newAccount {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		account = newAccount;
		
		journal = [account.user retain];
		security = PostSecurityPublic;
		selectedFriendGroups = [[NSMutableArray alloc] init];
		
		picKeyword = [[[AccountManager sharedManager] stateInfoForAccount:account.title].newPostPicKeyword retain];
		tags = [[[AccountManager sharedManager] stateInfoForAccount:account.title].newPostTags retain];
		mood = [[[AccountManager sharedManager] stateInfoForAccount:account.title].newPostMood retain];

		
#ifdef LITEVERSION
		promote = YES;
#else
		promote = [[AccountManager sharedManager] stateInfoForAccount:account.title].newPostPromote;
#endif

    	// iPod notikumi
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
		[notificationCenter addObserver:self selector:@selector(musicPlayerStateChanged:) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:musicPlayer];
		[notificationCenter addObserver:self selector:@selector(musicPlayerStateChanged:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:musicPlayer];
		[musicPlayer beginGeneratingPlaybackNotifications];
		[self musicPlayerStateChanged:musicPlayer];
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

	self.navigationItem.leftBarButtonItem = nil;
	
	[journal release];
}


- (void)done {
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#ifdef BETA

#ifndef LITEVERSION
    return 3;
#else
	return 2;
#endif
	
#else // BETA
	
#ifndef LITEVERSION
    return 2;
#else
	return 1;
#endif
	
#endif // BETA
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) return 2;
#ifdef BETA
	if (section == 1) return 4;
#endif
	return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// nosak šūnas veidu
	NSUInteger cellKind;
	if (indexPath.section == SectionBasic) {
		if (indexPath.row == SectionBasicRowJournal) { cellKind = SimpleCell; }
		else if (indexPath.row == SectionBasicRowSecurity) { cellKind = SimpleCell; };
#ifdef BETA
	} else if (indexPath.section == SectionAdditional) {
		if (indexPath.row == SectionAdditionalRowPicture) { cellKind = SimpleCell; }
		else if (indexPath.row == SectionAdditionalRowTags) { cellKind = TextFieldCell; }
		else if (indexPath.row == SectionAdditionalRowMood) { cellKind = TextFieldCell; }
		else if (indexPath.row == SectionAdditionalRowMusic) { cellKind = TextFieldCell; };
#endif // BETA
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
			cell.detailTextLabel.text = journal;
		} else if (indexPath.row == 1) {
			cell.textLabel.text = NSLocalizedString(@"Security", nil);
			if (security == PostSecurityPublic) {
				cell.detailTextLabel.text = NSLocalizedString(@"Public", nil);
			} else if (security == PostSecurityFriends) {
				cell.detailTextLabel.text = NSLocalizedString(@"Friends only", nil);
			} else if (security == PostSecurityPrivate) {
				cell.detailTextLabel.text = NSLocalizedString(@"Private", nil);
			} else {
				cell.detailTextLabel.text = NSLocalizedString(@"Custom", nil);
			}
		}
#ifdef BETA
	} else if (indexPath.section == SectionAdditional) {
		if (indexPath.row == SectionAdditionalRowPicture) {
			cell.textLabel.text = NSLocalizedString(@"Userpic", nil);
			cell.detailTextLabel.text = picKeyword ? picKeyword : NSLocalizedString(@"Default", nil);
		} else if (indexPath.row == SectionAdditionalRowTags) {
			cell.textLabel.text = NSLocalizedString(@"Tags", nil);
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			[(TextFieldCellView *)cell setTags:tags];
			((TextFieldCellView *)cell).text.placeholder = NSLocalizedString(@"separated by commas", nil);
			[(TextFieldCellView *)cell setTarget:self action:@selector(tagsChanged:)];
		} else if (indexPath.row == SectionAdditionalRowMood) {
			cell.textLabel.text = NSLocalizedString(@"Mood", nil);
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			((TextFieldCellView *)cell).text.text = mood;
			((TextFieldCellView *)cell).text.placeholder = NSLocalizedString(@"select from list or type here", nil);
			[(TextFieldCellView *)cell setTarget:self action:@selector(moodChanged:)];
		} else if (indexPath.row == SectionAdditionalRowMusic) {
			cell.textLabel.text = NSLocalizedString(@"Music", nil);
			cell.accessoryType = UITableViewCellAccessoryNone;
			((TextFieldCellView *)cell).text.text = music;
			((TextFieldCellView *)cell).text.placeholder = currentSong;
			[(TextFieldCellView *)cell setTarget:self action:@selector(musicChanged:)];
		}
#endif // BETA
	} else if (indexPath.section == SectionPromote) {
		cell.textLabel.text = NSLocalizedString(@"Promote Journaler", nil);
		UISwitch *cellSwitch = (UISwitch *)[cell viewWithTag:SwitchTag];
		cellSwitch.on = promote;
		
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

#ifdef BETA
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	UIViewController *controller;
	
	if (indexPath.section == SectionAdditional && indexPath.row == SectionAdditionalRowTags) {
		controller = [[TagListController alloc] initWithPostOptionsController:self];
	} else	if (indexPath.section == SectionAdditional && indexPath.row == SectionAdditionalRowMood) {
		controller = [[MoodListController alloc] initWithPostOptionsController:self];
	}
	
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];	
}
#endif

- (void)dealloc {
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	// iPod notikumi
	[notificationCenter removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:musicPlayer];
	[notificationCenter removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:musicPlayer];
	[musicPlayer endGeneratingPlaybackNotifications]; 
	
	[selectedFriendGroups release];
	[tags release];
	[mood release];
	
	[super dealloc];
}

- (void)tagsChanged:(id)sender {
	self.tags = ((TextFieldCellView *)sender).tags;
}

- (void)moodChanged:(id)sender {
	self.mood = ((TextFieldCellView *)sender).text.text;
}

- (void)musicChanged:(id)sender {
	self.music = ((TextFieldCellView *)sender).text.text;
}

- (void)promoteChanged:(id)sender {
	promote = ((UISwitch *)sender).on;
	[[AccountManager sharedManager] stateInfoForAccount:account.title].newPostPromote = promote;
}

- (void)setPicKeyword:(NSString *)newPicKeyword {
	if (newPicKeyword != picKeyword) {
		[picKeyword release];
		picKeyword = [newPicKeyword retain];
		
		[[AccountManager sharedManager] stateInfoForAccount:account.title].newPostPicKeyword = picKeyword;
	}
}

- (void)setTags:(NSSet *)newTags {
	if (newTags != tags) {
		[tags release];
		tags = [newTags retain];

		[[AccountManager sharedManager] stateInfoForAccount:account.title].newPostTags = tags;
	}
}

- (void)setMood:(NSString *)newMood {
	if (newMood != mood) {
		[mood release];
		mood = [newMood retain];

		[[AccountManager sharedManager] stateInfoForAccount:account.title].newPostMood = mood;
	}
}

- (void)setMusic:(NSString *)newMusic {
	if (newMusic != music) {
		[music release];
		music = [newMusic retain];
		
		[[AccountManager sharedManager] stateInfoForAccount:account.title].newPostMusic = music;
	}
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
	
#ifdef BETA
	TextFieldCellView *cell = (TextFieldCellView *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SectionAdditionalRowMusic inSection:SectionAdditional]];
	cell.text.placeholder = currentSong;
#endif
}

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

@end

