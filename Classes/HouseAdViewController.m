//
//  HouseAdViewController.m
//  Journaler
//
//  Created by Natālija Dudareva on 7/13/10.
//  Copyright 2010 A25. All rights reserved.
//

#import "HouseAdViewController.h"
#import "HouseAdManager.h"

@implementation HouseAdViewController

@synthesize imageView;
@synthesize url;

- (void)countDown {
	if (timeLeft) {
		dismissButton.titleLabel.text = [NSString stringWithFormat:@"%d", timeLeft];
		timeLeft--;
		[self performSelector:@selector(countDown) withObject:nil afterDelay:1.0f];
	} else {
		dismissButton.enabled = YES;
		dismissButton.titleLabel.text = NSLocalizedString(@"Dismiss", nil);
	}
}

- (IBAction)dismiss {
	[self dismissModalViewControllerAnimated:YES];
	[[HouseAdManager houseAdManager] dismissAd];
}

- (IBAction)goToURL {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	[[HouseAdManager houseAdManager] dismissAd];
}

- (void)dealloc {
	[dismissButton release];
//	[imageView release];
	
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
	if (!imageView.image) {
		imageView.image = [UIImage imageNamed:@"selfad.png"];
		url = @"http://itunes.apple.com/app/journaler/id338132860?mt=8";
	}
	
	dismissButton.titleLabel.textAlignment = UITextAlignmentCenter;
}

- (void)viewDidAppear:(BOOL)animated {
#ifdef LITEVERSION
	timeLeft = 5;
	[self countDown];
#else
	dismissButton.enabled = YES;
	dismissButton.titleLabel.text = NSLocalizedString(@"Dismiss", nil);
#endif
}

@end