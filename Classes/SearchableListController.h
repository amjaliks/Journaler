//
//  TagListController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 20.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostOptionsController;

@interface SearchableListController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate> {
	PostOptionsController *postOptionsController;
	
	NSMutableArray *filteredList;
	NSArray *fullList;
	
	// pazīme, ka saraksts jau tika atjaunots
	BOOL listRefreshed;
}

@property (nonatomic, retain) NSArray *fullList;

- (id)initWithPostOptionsController:(PostOptionsController *)postOptionsController;
- (UITableViewCell *)cell:(UITableViewCell *)cell forItem:(id)item;
- (void)didSelectCell:(UITableViewCell *)cell withItem:(id)item;
- (void)updateFullListWithNewItem:(id)item;
- (void)filterListForSearchString:(NSString *)searchString;
- (BOOL)item:(id)item conformsSearchString:(NSString *)searchString;
- (id)fakeItemForSearchString:(NSString *)searchString;
- (void)repeatSearch;
- (void)refreshFullList;

@end
