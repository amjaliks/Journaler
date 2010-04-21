//
//  TagListController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 20.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostOptionsController;

@interface TagListController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate> {
	PostOptionsController *postOptionsController;
	
	NSMutableArray *filteredTags;
	NSArray *allTags;
	
	NSMutableArray *selectedTags;
}

- (id)initWithPostOptionsController:(PostOptionsController *)postOptionsController;
- (void)filterTagsForSearchString:(NSString *)searchString;
- (void)updateAllTagsWithNewTag:(NSString *)newTag;
- (void)repeatSearch;
- (void)refreshTagsFromServer;

@end
