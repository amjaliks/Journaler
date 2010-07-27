//
//  TellAFriendController.m
//  Journaler
//
//  Created by Natālija Dudareva on 7/27/10.
//  Copyright 2010 A25. All rights reserved.
//

#import "TellAFriendController.h"
#import "ErrorHandling.h"

#import "ALDeviceInfo.h"
#import "AccountManager.h"

@implementation TellAFriendController

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([MFMailComposeViewController canSendMail]) {
		return 4;
	} else {
		return 3;
	}

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textLabel.textAlignment = UITextAlignmentCenter;
    }
	
	if ([MFMailComposeViewController canSendMail]) {
		if (indexPath.row == 0) {
			cell.textLabel.text = NSLocalizedString(@"E-mail", nil);
		} else if (indexPath.row == 1) {
			cell.textLabel.text = NSLocalizedString(@"Twitter", nil);
		} else if (indexPath.row == 2) {
			cell.textLabel.text = NSLocalizedString(@"Facebook", nil);
		} else {
			cell.textLabel.text = NSLocalizedString(@"LiveJournal", nil);
		}
	} else {
		if (indexPath.row == 0) {
			cell.textLabel.text = NSLocalizedString(@"Twitter", nil);
		} else if (indexPath.row == 1) {
			cell.textLabel.text = NSLocalizedString(@"Facebook", nil);
		} else {
			cell.textLabel.text = NSLocalizedString(@"LiveJournal", nil);
		}
	}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([MFMailComposeViewController canSendMail] && (indexPath.row == 0)) {
		
		NSString *device = [UIDevice currentDevice].model;
		NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Hi!\n\nI found a really cool LiveJournal client for my %@. I think you may interested to check it out as well: http://itunes.com/app/journaler", nil), device];
		
		MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
		mailController.mailComposeDelegate = self;
		
		[mailController setSubject:NSLocalizedString(@"Check out Journaler app!", nil)];
		[mailController setMessageBody:message isHTML:NO];
		
		[self presentModalViewController:mailController animated:YES];
		[mailController release];
	}
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
	if (result == MFMailComposeResultSent) {
		[[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success!", nil) message:NSLocalizedString(@"Mail has been sent", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
	} else if (result == MFMailComposeResultFailed) {
		showErrorMessage(NSLocalizedString(@"Sending error", nil), decodeError([error code]));	
	}
}

#pragma mark Incializācija un atmiņas pārvaldīšana

- (void)dealloc {
    [super dealloc];
}


@end

