//
//  LegalController.m
//  Journaler
//
//  Created by Natālija Dudareva on 7/2/10.
//  Copyright 2010 A25. All rights reserved.
//

#import "LegalController.h"


@implementation LegalController

@synthesize webView;

- (void)viewDidLoad {
    [super viewDidLoad];

	NSString *path = [[NSBundle mainBundle] pathForResource:@"Legal" ofType:@"html"];
	NSURL *URL = [NSURL fileURLWithPath:path];
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	[webView loadRequest:request];
}

#ifndef LITEVERSION
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIDeviceOrientationPortrait || UIDeviceOrientationIsLandscape(interfaceOrientation);
}
#endif

- (void)dealloc {
    [super dealloc];
}


@end
