//
//  UIViewAdditions.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 24.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIView (UIViewAdditions) 

- (BOOL)findAndResignFirstResonder;
- (void)resizeForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (UIViewController *)viewController;

@end
