//
//  SelfAdViewController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.04.08.
//  Copyright 2010 A25. All rights reserved.
//

#import "SelfAdViewController.h"


@implementation SelfAdViewController

- (void)startCountDown {
	dismissButton.titleLabel.textAlignment = UITextAlignmentCenter;
	timeLeft = 5;
	[self countDown];
}

- (void)countDown {
	if (timeLeft) {
		dismissButton.titleLabel.text = [NSString stringWithFormat:@"%d", timeLeft];
		timeLeft--;
		[self performSelector:@selector(countDown) withObject:nil afterDelay:1.0f];
	} else {
		dismissButton.enabled = YES;
		dismissButton.titleLabel.text = @"Dismiss";
	}
}

- (IBAction)gotoAppStore {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/app/journaler/id338132860?mt=8"]];
}

- (IBAction)dismiss {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    [super dealloc];
}


@end
