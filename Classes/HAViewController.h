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
	NSString *URL;
	
	IBOutlet UIButton *dismissButton;
	IBOutlet UIImageView *imageView;
}

- (IBAction)dismiss;
- (IBAction)goToURL;

@property (assign) UIImageView *imageView;
@property (assign) NSString *URL;

@end
