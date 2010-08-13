//
//  FilterOptionsController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.05.03.
//  Copyright 2010 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FriendsPageFilter.h"

@class FriendsPageController;

@interface FilterOptionsController : UITableViewController {
	FriendsPageController *friendsPageController;
	
	NSInteger numberOfSections;
	NSInteger sectionJournalType;
	NSInteger sectionGroup;
	
	UITableViewCell *selectedCell;
	FriendsPageFilter *previousFilter;
}

- (id)initWithFriendsPageController:(FriendsPageController *)friendsPageController;
- (void)updateNumberOfSections;
- (void)done:(id)sender;
- (void)refresh:(id)sender;
- (void)refreshSelectedGroup;

@end
