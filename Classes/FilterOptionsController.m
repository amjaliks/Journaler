//
//  FilterOptionsController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.05.03.
//  Copyright 2010 A25. All rights reserved.
//

#import "FilterOptionsController.h"

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
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

#ifndef LITEVERSION
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait)
			|| UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
#endif


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == FilterTypeAll) { return 1; }
	else if (section == FilterTypeJournalType) { return 3; }
	else { return 0; };
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == FilterTypeAll) { return NSLocalizedString(@"All journals", nil); }
	else if (section == FilterTypeJournalType) { return NSLocalizedString(@"Journal type", nil); }
	else { return nil; };
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
		cell.textLabel.text = NSLocalizedString(@"All journals", nil);
		cell.accessoryType = friendsPageController.friendsPageFilter.filterType == FilterTypeAll ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	} else if (indexPath.section == FilterTypeJournalType) {
		BOOL selected = friendsPageController.friendsPageFilter.filterType == FilterTypeJournalType;
		if (indexPath.row == JournalTypeJournals) {
			cell.textLabel.text = NSLocalizedString(@"Journals", nil);
			cell.accessoryType = (selected && friendsPageController.friendsPageFilter.journalType == JournalTypeJournals) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
		} else	if (indexPath.row == JournalTypeCommunities) {
			cell.textLabel.text = NSLocalizedString(@"Communities", nil);
			cell.accessoryType = (selected && friendsPageController.friendsPageFilter.journalType == JournalTypeCommunities) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
		} else	if (indexPath.row == JournalTypeSyndications) {
			cell.textLabel.text = NSLocalizedString(@"Syndication feeds", nil);
			cell.accessoryType = (selected && friendsPageController.friendsPageFilter.journalType == JournalTypeSyndications) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
		}
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
	friendsPageController.friendsPageFilter.filterType == indexPath.section;
	if (indexPath.section == FilterTypeJournalType) {
		friendsPageController.friendsPageFilter.journalType == indexPath.row;
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

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark -
#pragma mark UI button actions

- (void)done:(id)sender {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


@end

