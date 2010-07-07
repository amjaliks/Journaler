//
//  CommentController.h
//  Journaler
//
//  Created by Natālija Dudareva on 7/6/10.
//  Copyright 2010 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentController : UIViewController<UITextViewDelegate> {
	UIBarButtonItem *postButton;

	UITextView *textView;
}

- (void)cancel:(id)sender;
- (void)post:(id)sender;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardDidHide:(NSNotification *)notification;

@end
