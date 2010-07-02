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

#define kStringTable @"AppSettings"

@implementation SettingsController

@synthesize refreshOnStartCell;
@synthesize legalController;

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
	else return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = indexPath.section;
	
	NSString *cellId;
	if (section == 0) {
		cellId = @"RefreshOnStart";
	} else {
		if (indexPath.row == 0) 
			cellId = @"Version";
		else 
			cellId = @"Legal";
	}
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
		if (section == 0) {
			cell = refreshOnStartCell;
			UISwitch *sw = (UISwitch *)[cell viewWithTag:1];
			sw.on = DEFAULT_BOOL(kSettingsRefreshOnStart);
		} else {
			if (indexPath.row == 0) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				cell.textLabel.text = NSLocalizedStringFromTable(@"Version", @"Version", nil);
				cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
			} else {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
				
				cell.textLabel.text = NSLocalizedStringFromTable(@"Legal", @"Legal", nil);
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
		}

    }
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ((indexPath.section == 1) && (indexPath.row == 1)) {
		[self.navigationController pushViewController:legalController animated:YES];
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

@end

