//
//  PostPreviewView.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.23.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Post;

@interface PostPreviewView : UIView {
	Post *post;

	BOOL highlighted;
	
	UIFont *subjectFont;
	UIFont *userFont;
	UIFont *communityFont;
	UIFont *dateTimeRepliesFont;
	UIFont *textFont;
	CGFloat inWidth;
	
	NSDateFormatter *f;
}

@property (nonatomic, getter=isHighlighted) BOOL highlighted;

- (void) setPost:(Post *)post;

@end
