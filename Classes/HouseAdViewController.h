//
//  HouseAdViewController.h
//  Journaler
//
//  Created by Natālija Dudareva on 7/13/10.
//  Copyright 2010 A25. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HouseAdViewController : UIViewController {
	IBOutlet UIButton *dismissButton;
	
	IBOutlet UIImageView *imageView;
}

- (void)startShowing:(UIImage *)image;

- (IBAction)dismiss;

@end
