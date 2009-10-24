//
//  PostSummaryCell.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.24.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Post;

@interface PostSummaryCell : UITableViewCell {
	UITableView *tableView;
	Post *post;
}

@property (retain) UITableView *tableView;
@property (retain) Post *post;

- (void) setUserPic:(UIImage *)image;

@end
