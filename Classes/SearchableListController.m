//
//  TagListController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 20.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import "SearchableListController.h"
#import "PostOptionsController.h"
#import "LiveJournal.h"

@implementation SearchableListController

@synthesize fullList;

- (id)initWithPostOptionsController:(PostOptionsController *)newPostOptionsController {
    if (self = [super initWithNibName:@"SearchableListController" bundle:nil]) {
		postOptionsController = newPostOptionsController;
		listRefreshed = NO;
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self updateFullListWithNewItem:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	filteredList = [[NSMutableArray alloc] init];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

	[fullList release];
}

#ifndef LITEVERSION
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIDeviceOrientationPortrait || UIDeviceOrientationIsLandscape(interfaceOrientation);
}
#endif

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
		return [filteredList count];
	} else {
		return [fullList count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    id item;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
		item = [filteredList objectAtIndex:indexPath.row];
	} else {
		item = [fullList objectAtIndex:indexPath.row];
	}
	    
	return [self cell:cell forItem:item];
}

- (UITableViewCell *)cell:(UITableViewCell *)cell forItem:(id)item {
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id item;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
		item = [filteredList objectAtIndex:indexPath.row];
	} else {
		item = [fullList objectAtIndex:indexPath.row];
	}
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	[self didSelectCell:cell withItem:item];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didSelectCell:(UITableViewCell *)cell withItem:(id)item {
	// nothing
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [filteredList release];
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Search

- (void)updateFullListWithNewItem:(id)item {
	// nothing;
}

- (void)filterListForSearchString:(NSString *)searchString {
	[filteredList removeAllObjects];
	
	for (id item in fullList) {
		if ([self item:item conformsSearchString:searchString]) {
			[filteredList addObject:item];
		}
	}
	
	if (![filteredList count]) {
		if (!listRefreshed) {
			listRefreshed = YES;
			[self performSelectorInBackground:@selector(refreshFullList) withObject:nil];
		}
		
		[filteredList addObject:[self fakeItemForSearchString:searchString]];
	}
}

- (BOOL)item:(id)item conformsSearchString:(NSString *)searchString {
	return YES;
}

- (id)fakeItemForSearchString:(NSString *)searchString {
	return nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	[self filterListForSearchString:searchString];
	return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self.tableView reloadData];
}

- (void)repeatSearch {
	if (self.searchDisplayController.active) {
		[self filterListForSearchString:self.searchDisplayController.searchBar.text];
		[self.searchDisplayController.searchResultsTableView reloadData];
	}
}

- (void)refreshFullList {
	// nothing
}

@end

