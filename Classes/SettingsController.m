//
//  SettingsController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.01.10.
//  Copyright 2010 A25. All rights reserved.
//

#import "SettingsController.h"
#import "Macros.h"
#import "Settings.h"
#import "SettingsStartUpScreenController.h"
#import "ErrorHandler.h"

#define kStringTable @"AppSettings"

@implementation SettingsController

#pragma mark Incializācija un atmiņas pārvaldīšana

- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.title = @"Settings";
	
	UIBarButtonItem *doneButtoneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.leftBarButtonItem = doneButtoneItem;
	[doneButtoneItem release];
}

- (void)dealloc {
    [super dealloc];
}

#ifndef LITEVERSION
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIDeviceOrientationPortrait || UIDeviceOrientationIsLandscape(interfaceOrientation);
}
#endif

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
	else return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = indexPath.section;
	
	NSString *cellId;
	if (section == 0) {
		cellId = @"RefreshOnStart";
	} else {
		cellId = @"Cell";
	}
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
		if (section == 0) {
			cell = refreshOnStartCell;
			UISwitch *sw = (UISwitch *)[cell viewWithTag:1];
			sw.on = DEFAULT_BOOL(kSettingsRefreshOnStart);
		} else {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];

			if (indexPath.row == 0) {
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.accessoryType = UITableViewCellAccessoryNone;
				
				cell.textLabel.text = NSLocalizedString(@"Version", nil);
				cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
			} else if (indexPath.row == 1) {
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.accessoryType = UITableViewCellAccessoryNone;
				
				cell.textLabel.text = NSLocalizedString(@"Tell a friend", nil);
				cell.detailTextLabel.text = nil;
			} else {
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

				cell.textLabel.text = NSLocalizedString(@"Legal", nil);
				cell.detailTextLabel.text = nil;
			}
		}

    }
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1) {
		if (indexPath.row == 1) {
			if ([MFMailComposeViewController canSendMail]) {
				[self sendMail];
			} else {
				showErrorMessage(NSLocalizedString(@"No email account", nil), NSLocalizedString(@"Please setup email account in Settings", nil));	
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
			}
		} else if (indexPath.row == 2) {
			[self.navigationController pushViewController:legalController animated:YES];
		}
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return section == 0 ? NSLocalizedStringFromTable(@"General", @"General", kStringsTable) : NSLocalizedStringFromTable(@"About", @"About", kStringsTable);
}

#pragma mark Iestatījum izmaiņu apstrāde

- (IBAction) refreshOnStartChanged {
	UISwitch *sw = (UISwitch *)[refreshOnStartCell viewWithTag:1];
	[DEFAULTS setBool:sw.on forKey:kSettingsRefreshOnStart];
}

#pragma mark Saskarnes elementi
			
- (void)done {
	[self dismissModalViewControllerAnimated:YES];
}

+ (NSString *)decodeStartUpScreenValue:(NSString *)value {
	if ([kStartUpScreenAccountList isEqualToString:value]) {
		return @"Account list";
	} else if ([kStartUpScreenFriendsPage isEqualToString:value]) {
		return @"Friends page";
	} else if ([kStartUpScreenLastView isEqualToString:value]) {
		return @"Last view";
	}
	return nil;
}

#pragma mark Mail sending

- (void)sendMail {
	NSString *device = [UIDevice currentDevice].model;
	NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Hi!\n\nI found a really cool LiveJournal client for my %@. I think you may interested to check it out as well: http://itunes.com/app/journaler", nil), device];
	
	MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
	mailController.mailComposeDelegate = self;

	[mailController setSubject:NSLocalizedString(@"Check out Journaler app!", nil)];
	[mailController setMessageBody:message isHTML:NO];

	[self presentModalViewController:mailController animated:YES];
	[mailController release];
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
	if (result == MFMailComposeResultSent) {
		showErrorMessage(NSLocalizedString(@"Thank you!", nil), NSLocalizedString(@"Mail has been sent", nil));	
	} else if (result == MFMailComposeResultFailed) {
		showErrorMessage(NSLocalizedString(@"Sending error", nil), NSLocalizedString(@"Something has gone wrong, please try again!", nil));	
	}
}


@end

