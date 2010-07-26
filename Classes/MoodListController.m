//
//  MoodListController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 23.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import "MoodListController.h"
#import "PostOptionsController.h"
#import "LiveJournal.h"
#import "AccountManager.h"
#import "NSSetAdditions.h"

@implementation MoodListController

- (void)updateFullListWithNewItem:(id)newItem {
	@synchronized (self) {
		NSMutableSet *set = [[NSMutableSet alloc] initWithSet:postOptionsController.account.moods];
		
		// noskaņojums no raksta
		if ([postOptionsController.mood length]) {
			LJMood *mood = [set member:[[[LJMood alloc] initWithMood:postOptionsController.mood] autorelease]];
			if (!mood) {
				mood = [[LJMood alloc] initWithID:0 mood:postOptionsController.mood];
				[set addObject:mood];
				[mood release];
			}
		}
		
		// jaunais tags
		if (newItem) {
			[set addObject:newItem];
		}
		
		self.fullList = [set sortedArray];

		[set release];
	}
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"Mood", nil);
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	selectedMood = [[LJMood alloc] initWithID:0 mood:postOptionsController.mood];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	postOptionsController.mood = selectedMood.mood;
	[selectedMood release];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Table view data source

- (UITableViewCell *)cell:(UITableViewCell *)cell forItem:(id)item {
	cell.textLabel.text = [item mood];
	if ([item isEqual:selectedMood]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		selectedCell = cell;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)didSelectCell:(UITableViewCell *)cell withItem:(id)item {
	if (![selectedMood isEqual:item]) {
		selectedCell.accessoryType = UITableViewCellAccessoryNone;
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		selectedCell = cell;
		
		[selectedMood release];
		selectedMood = [item retain];
		
		if (![fullList containsObject:item]) {
			[self updateFullListWithNewItem:item];
		}		
	}
}

#pragma mark -
#pragma mark Search

- (BOOL)item:(id)item conformsSearchString:(NSString *)searchString {
	NSComparisonResult result = [[item mood] compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
	return result == NSOrderedSame;
}

- (id)fakeItemForSearchString:(NSString *)searchString {
	return [[[LJMood alloc] initWithID:0 mood:searchString] autorelease];
}

- (void)refreshFullList {
	if (!postOptionsController.account.loginSynchronized) {
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		LJAPIClient *manager = [LJAPIClient client];
		if ([manager loginForAccount:postOptionsController.account error:nil]) {
			[self updateFullListWithNewItem:nil];
			[self performSelectorOnMainThread:@selector(repeatSearch) withObject:nil waitUntilDone:NO];
			
			[[AccountManager sharedManager] storeAccounts];
		}
		
		[pool release];
		
	}
}

@end
