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

- (void)startShowing:(UIImage *)image {
	imageView.image = image;
	
	dismissButton.titleLabel.textAlignment = UITextAlignmentCenter;
	dismissButton.enabled = YES;
	dismissButton.titleLabel.text = @"Dismiss";
}

- (IBAction)dismiss {
	[self dismissModalViewControllerAnimated:YES];
	[[HouseAdManager houseAdManager] dismissAd];
}

- (void)dealloc {
	[dismissButton release];
	[imageView release];
	
    [super dealloc];
}


@end
