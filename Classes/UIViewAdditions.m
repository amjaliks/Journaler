//
//  UIViewAdditions.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 24.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import "UIViewAdditions.h"

@implementation UIView (FindAndResignFirstResponder)


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

@end

