//
//  PicKeywordListController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 23.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@class PostOptionsController;

@interface PicKeywordListController : UITableViewController {
	PostOptionsController *postOptionsController;
	
	UITableViewCell *selectedCell;
}

- (id)initWithPostOptionsController:(PostOptionsController *)postOptionsController;
- (void)refresh;

@end