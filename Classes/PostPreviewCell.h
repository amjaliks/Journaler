//
//  PostPreviewCell.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.23.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostPreviewView, Post;

@interface PostPreviewCell : UITableViewCell {
	PostPreviewView *view;
}

- (void) setPost:(Post *)post;

@end
