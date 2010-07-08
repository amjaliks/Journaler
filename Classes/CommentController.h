//
//  CommentController.h
//  Journaler
//
//  Created by Natālija Dudareva on 7/6/10.
//  Copyright 2010 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Post, LJAccount;

@interface CommentController : UIViewController<UITextViewDelegate> {
	LJAccount *account;
	Post *post;
	
	UIBarButtonItem *postButton;

	UITextView *textView;
}

- (id)initWithPost:(Post *)post account:(LJAccount *)account;

- (void)cancel:(id)sender;
- (void)post:(id)sender;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardDidHide:(NSNotification *)notification;

@end
