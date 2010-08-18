//
//  SettingsController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.01.10.
//  Copyright 2010 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SettingsController : UITableViewController<MFMailComposeViewControllerDelegate> {
	IBOutlet UITableViewCell *refreshOnStartCell;
	IBOutlet UIViewController *legalController;
	IBOutlet UITableViewController *tellAFriendController;
}

- (IBAction)refreshOnStartChanged;
- (void)done;

- (void)sendMail;

+ (NSString *)decodeStartUpScreenValue:(NSString *)value;

@end
