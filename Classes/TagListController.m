//
//  TagListController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 20.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import "TagListController.h"
#import "PostOptionsController.h"

@implementation TagListController

- (id)initWithPostOptionsController:(PostOptionsController *)newPostOptionsController {
    if (self = [super initWithNibName:@"TagListController" bundle:nil]) {
		postOptionsController = newPostOptionsController;
    }
    return self;
}

- (void)updateAllTagsWithNewTag:(NSString *)newTag {
	NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[postOptionsController.tags count] + newTag ? 1 : 0];
	
	[tempArray addObjectsFromArray:postOptionsController.tags];
	if (newTag) {
		[tempArray addObject:newTag];
	}
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	allTags = [[tempArray sortedArrayUsingDescriptors:sortDescriptors] retain];
	
	[sortDescriptors release];
	[sortDescriptor release];
	[tempArray release];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = NSLocalizedString(@"Tags", nil);
	
	filteredTags = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[self updateAllTagsWithNewTag:nil];
	
	selectedTags = [postOptionsController.tags mutableCopy];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

	postOptionsController.tags = selectedTags;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

	[allTags release];
	[selectedTags release];
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
		return [filteredTags count];
	} else {
		return [allTags count];
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSString *tag;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
		tag = [filteredTags objectAtIndex:indexPath.row];
	} else {
		tag = [allTags objectAtIndex:indexPath.row];
	}
	
	cell.textLabel.text = tag;
	cell.accessoryType = [selectedTags containsObject:tag] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tag;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
		tag = [filteredTags objectAtIndex:indexPath.row];
	} else {
		tag = [allTags objectAtIndex:indexPath.row];
	}
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if ([selectedTags containsObject:tag]) {
		[selectedTags removeObject:tag];
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else {
		[selectedTags addObject:tag];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		
		if (![allTags containsObject:tag]) {
			[self updateAllTagsWithNewTag:tag];
		}
	}
	
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
    [filteredTags release];
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Search

- (void)filterTagsForSearchString:(NSString *)searchString {
	//[filteredTags release];
	
	//NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	[filteredTags removeAllObjects];
	
	for (NSString *tag in allTags) {
		NSComparisonResult result = [tag compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
		if (result == NSOrderedSame) {
			[filteredTags addObject:tag];
		}
	}
	
	if (![filteredTags count]) {
		[filteredTags addObject:searchString];
	}
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	[self filterTagsForSearchString:searchString];
	
	return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self.tableView reloadData];
}

@end

