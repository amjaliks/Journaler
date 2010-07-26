//
//  TagListController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 23.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import "TagListController.h"

#import "PostOptionsController.h"
#import "LiveJournal.h"
#import "NSSetAdditions.h"
#import "AccountManager.h"

@implementation TagListController

- (void)updateFullListWithNewItem:(id)newItem {
	@synchronized (self) {
		NSMutableSet *set = [[NSMutableSet alloc] init];
		
		// tagu saraksts no konta
		[set addObjectsFromSet:postOptionsController.account.tags];
		
		// tagi no raksta
		[set addObjectsFromSet:postOptionsController.tags];
		
		// jaunais tags
		if (newItem) {
			[set addObject:newItem];
		}
		
		self.fullList = [[set sortedArray] retain];
		
		[set release];
	}
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"Tags", nil);
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (postOptionsController.tags) {
		selectedTags = [postOptionsController.tags mutableCopy];
	} else {
		selectedTags = [[NSMutableSet alloc] init];
	}

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	
	postOptionsController.tags = selectedTags;
	[selectedTags release];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
	
	[selectedTags release];
}

#pragma mark -
#pragma mark Table view data source

- (UITableViewCell *)cell:(UITableViewCell *)cell forItem:(id)item {
	cell.textLabel.text = [item name];
	cell.accessoryType = [selectedTags containsObject:item] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)didSelectCell:(UITableViewCell *)cell withItem:(id)item {
	if ([selectedTags containsObject:item]) {
		[selectedTags removeObject:item];
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else {
		[selectedTags addObject:item];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		
		if (![fullList containsObject:item]) {
			[self updateFullListWithNewItem:item];
		}
	}
}

#pragma mark -
#pragma mark Search

- (BOOL)item:(id)item conformsSearchString:(NSString *)searchString {
	NSComparisonResult result = [[item name] compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
	return result == NSOrderedSame;
}

- (id)fakeItemForSearchString:(NSString *)searchString {
	return [[[LJTag alloc] initWithName:searchString] autorelease];
}

- (void)refreshFullList {
	if (!postOptionsController.account.tagsSynchronized) {

		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		LJAPIClient *manager = [LJAPIClient client];
		if ([manager userTagsForAccount:postOptionsController.account error:nil]) {
			[self updateFullListWithNewItem:nil];
			[self performSelectorOnMainThread:@selector(repeatSearch) withObject:nil waitUntilDone:NO];
			
			[[AccountManager sharedManager] storeAccounts];
		}
		
		[pool release];

	}
}

@end
