//
//  SettingsStartUpScreenController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.01.18.
//  Copyright 2010 A25. All rights reserved.
//

#import "SettingsStartUpScreenController.h"
#import "SettingsController.h"

#import "Settings.h"

@implementation SettingsStartUpScreenController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Start up screen";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSString *value;
	if (indexPath.row == 0) {
#ifndef LITEVERSION
		value = kStartUpScreenAccountList;
#else
		value = kStartUpScreenFriendsPage;
#endif
	} else {
		value = kStartUpScreenLastView;
	}
	
	cell.textLabel.text = [SettingsController decodeStartUpScreenValue:value];
	cell.accessoryType = [value isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:kSettingsStartUpScreen]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *value;
	if (indexPath.row == 0) {
#ifndef LITEVERSION
		value = kStartUpScreenAccountList;
#else
		value = kStartUpScreenFriendsPage;
#endif
	} else {
		value = kStartUpScreenLastView;
	}
	
	[[NSUserDefaults standardUserDefaults] setValue:value forKey:kSettingsStartUpScreen];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc {
    [super dealloc];
}


@end

