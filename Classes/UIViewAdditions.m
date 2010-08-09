//
//  UIViewAdditions.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 24.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import "UIViewAdditions.h"

@implementation UIView (UIViewAdditions)


// http://stackoverflow.com/questions/1823317/how-do-i-legally-get-the-current-first-responder-on-the-screen-on-an-iphone
- (BOOL)findAndResignFirstResonder {
    if (self.isFirstResponder) {
        return [self resignFirstResponder];
    }
    for (UIView *subView in self.subviews) {
		if ([subView findAndResignFirstResonder]) {
			return YES;
		}
    }
    return NO;
}

- (void)resizeForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {}

// http://stackoverflow.com/questions/2309569/how-to-get-uiviewcontroller-of-a-uiviews-superview-in-iphone-sdk/2309978#2309978
- (UIViewController *)viewController {
	for (UIView *next = [self superview]; next; next = next.superview) {
		UIResponder *nextResponder = [next nextResponder];
		if ([nextResponder isKindOfClass:[UIViewController class]]) {
			return (UIViewController*)nextResponder;
		}
	}
	return nil;
}


@end

