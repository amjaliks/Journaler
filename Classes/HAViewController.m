//
//  HouseAdViewController.m
//  Journaler
//
//  Created by Natālija Dudareva on 7/13/10.
//  Copyright 2010 A25. All rights reserved.
//

#import "HAViewController.h"
#import "HAManager.h"

@implementation HAViewController

@synthesize imageView;
@synthesize URL;

- (IBAction)dismiss {
	[self dismissModalViewControllerAnimated:YES];
	[houseAdManager dismissAd];
}

- (IBAction)goToURL {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
	[houseAdManager dismissAd];
}

- (void)dealloc {
	[dismissButton release];
    [super dealloc];
}


@end
