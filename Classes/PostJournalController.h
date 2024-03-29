//
//  PostJournalController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.12.01.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostOptionsController;

@interface PostJournalController : UITableViewController {
	PostOptionsController *postOptionsController;
	
	UITableViewCell *selectedCell;
}

- (id)initWithPostOptionsController:(PostOptionsController *)postOptionsController;
- (void)refresh;

@end
