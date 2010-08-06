//
//  HouseAdViewController.h
//  Journaler
//
//  Created by Natālija Dudareva on 7/13/10.
//  Copyright 2010 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HAViewController : UIViewController {
	NSInteger timeLeft;
	NSString *url;
	
	IBOutlet UIButton *dismissButton;
	IBOutlet UIImageView *imageView;
}

- (void)countDown;
- (IBAction)dismiss;
- (IBAction)goToURL;

@property (assign) UIImageView *imageView;
@property (assign) NSString *url;

@end
