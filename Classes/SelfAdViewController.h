//
//  SelfAdViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.04.08.
//  Copyright 2010 A25. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SelfAdViewController : UIViewController {
	IBOutlet UIButton *dismissButton;
	NSUInteger timeLeft;
}

- (void)startCountDown;
- (void)countDown;

- (IBAction)gotoAppStore;
- (IBAction)dismiss;

@end
