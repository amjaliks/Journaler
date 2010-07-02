//
//  SettingsController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.01.10.
//  Copyright 2010 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsController : UITableViewController {
	UITableViewCell *refreshOnStartCell;
	UIViewController *legalController;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *refreshOnStartCell;
@property (nonatomic, retain) IBOutlet UIViewController *legalController;

- (IBAction)refreshOnStartChanged;
- (void)done;

+ (NSString *)decodeStartUpScreenValue:(NSString *)value;

@end
