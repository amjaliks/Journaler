//
//  PostSecurityController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.12.02.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostOptionsController;

@interface PostSecurityController : UITableViewController {
	PostOptionsController *postOptionsController;
}

- (id)initWithPostOptionsController:(PostOptionsController *)postOptionsController;
- (void)refresh;

@end
