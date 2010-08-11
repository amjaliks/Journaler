//
//  FilterOptionsController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.05.03.
//  Copyright 2010 A25. All rights reserved.
//

#import "FilterOptionsController.h"

#import "AccountManager.h"
#import "ErrorHandler.h"
#import "FriendsPageFilter.h"
#import "FriendsPageController.h"

enum {
	SectionAll,
	SectionType,
	SectionGroup
};

enum {
	SectionAllRowAll
};

enum {
	SectionTypeRowJournals,
	SectionTypeRowCommunities,
	SectionTypeRowSyndications
};

@implementation FilterOptionsController


#pragma mark -
#pragma mark Initialization

-(id)initWithFriendsPageController:(FriendsPageController *)newFriendsPageController {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		friendsPageController = newFriendsPageController;
		[self updateNumberOfSections];
	}
	return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedString(@"Filter", nil);
	
	// poga "Done"
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
	self.navigationItem.leftBarButtonItem = done;
	[done release];

	if ([friendsPageController.account supports:ServerFeatureFriendsPageFilterByGroup]) {
		// "refresh" rādam tikai gadījumā, ja serveris atbalsts filtrēšanu pēc grupām
		UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
		self.navigationItem.rightBarButtonItem = refreshButton;
		[refreshButton release];
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	previousFilter = [friendsPageController.friendsPageFilter copy];
	
	if (![friendsPageController.account.friends count]) {
		[self refresh:nil];
	}
}

#ifndef LITEVERSION
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait)
			|| UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
#endif


#pragma mark -
#pragma mark Table view data source

-(void)updateNumberOfSections {
	numberOfSections = 1;
	
	if ([friendsPageController.account supports:ServerFeatureFriendsPageFilterByJournalType]) {
		sectionJournalType = numberOfSections;
		numberOfSections++;
	} else {
		sectionJournalType = -1;
	}
	
	if ([friendsPageController.account supports:ServerFeatureFriendsPageFilterByGroup] && [friendsPageController.account.friendGroups count]) {
		sectionGroup = numberOfSections;
		numberOfSections++;
	} else {
		sectionGroup = -1;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return numberOfSections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == FilterTypeAll) return 1;
	if (section == sectionJournalType) return 3;
	if (section == sectionGroup) return [friendsPageController.account.friendGroups count];
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == sectionGroup) return NSLocalizedString(@"Groups", nil);
	return nil;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	
	BOOL selected;

	if (indexPath.section == FilterTypeAll) {
		selected = friendsPageController.friendsPageFilter.filterType == FilterTypeAll;

		cell.textLabel.text = NSLocalizedString(@"All journals", nil);
	} else if (indexPath.section == sectionJournalType) {
		selected = friendsPageController.friendsPageFilter.filterType == FilterTypeJournalType 
				&& friendsPageController.friendsPageFilter.journalType == indexPath.row;

		if (indexPath.row == LJJournalTypeJournal) {
			cell.textLabel.text = NSLocalizedString(@"Journals", nil);
		} else	if (indexPath.row == LJJournalTypeCommunity) {
			cell.textLabel.text = NSLocalizedString(@"Communities", nil);
		} else	if (indexPath.row == LJJournalTypeSyndication) {
			cell.textLabel.text = NSLocalizedString(@"Syndicated feeds", nil);
		}
	} else if (indexPath.section == sectionGroup) {
		LJFriendGroup *group = [friendsPageController.account.friendGroups objectAtIndex:indexPath.row];
		
		selected = friendsPageController.friendsPageFilter.filterType == FilterTypeGroup 
				&& [friendsPageController.friendsPageFilter.group isEqualToString:group.name];
		
		cell.textLabel.text = group.name;
	}
	
	if (selected) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		selectedCell = cell;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// iepriekš izvēlētai šūnai noņemam ķesīti
	selectedCell.accessoryType = UITableViewCellAccessoryNone;
	
	// saglabājam jauno filtru
	if (indexPath.section == 0) {
		friendsPageController.friendsPageFilter.filterType = FilterTypeAll;
	} else if (indexPath.section == sectionJournalType) {
		friendsPageController.friendsPageFilter.filterType = FilterTypeJournalType;
		friendsPageController.friendsPageFilter.journalType = indexPath.row;
	} else if (indexPath.section == sectionGroup) {
		friendsPageController.friendsPageFilter.filterType = FilterTypeGroup;
		friendsPageController.friendsPageFilter.group = [[friendsPageController.account.friendGroups objectAtIndex:indexPath.row] name];
	}
	
	// uzliekam izvēlētai šūnai ķeksīti
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	selectedCell = cell;
	
	// noņem izcelšanu
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [super dealloc];
}


#pragma mark -
#pragma mark UI button actions

- (void)done:(id)sender {
	if (![previousFilter isEqual:friendsPageController.friendsPageFilter]) {
		[friendsPageController filterFriendsPage];
	}
	[previousFilter release];
	
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)refresh:(id)sender {
	NSError *error;
	
	if ([client friendGroupsForAccount:friendsPageController.account error:&error]) {	
		[client friendsForAccount:friendsPageController.account error:&error];
		[accountManager storeAccounts];
		
		[self.tableView reloadData];
	} else {
		showErrorMessage(NSLocalizedString(@"Friend groups sync error", nil), decodeError([error code]));
	}
}


@end

