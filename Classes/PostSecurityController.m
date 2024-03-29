//
//  PostSecurityController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.12.02.
//  Copyright 2009 A25. All rights reserved.
//

#import "PostSecurityController.h"

#import "PostOptionsController.h"
#import "AccountManager.h"
#import "LiveJournal.h"
#import "LJAPIClient.h"

#import "ErrorHandler.h"

#define kStringsTable @"PostOptions"

@implementation PostSecurityController

- (id)initWithPostOptionsController:(PostOptionsController *)newPostOptionsController {
	self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
		postOptionsController = newPostOptionsController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = @"Security";
	
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
	self.navigationItem.rightBarButtonItem = refreshButton;
	[refreshButton release];
}

#ifndef LITEVERSION
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIDeviceOrientationPortrait || UIDeviceOrientationIsLandscape(interfaceOrientation);
}
#endif

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.navigationItem.rightBarButtonItem = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [postOptionsController.account.friendGroups count] > 0 ? 2 : 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 3 : [postOptionsController.account.friendGroups count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return section == 0 ? NSLocalizedString(@"Security level", nil) : NSLocalizedString(@"Groups", nil);
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			cell.textLabel.text = NSLocalizedStringFromTable(@"Public", @"Name for public security level", kStringsTable);
		} else if (indexPath.row == 1) {
			cell.textLabel.text = NSLocalizedStringFromTable(@"Friends only", @"Name for friends-only security level", kStringsTable);
		} else if (indexPath.row == 2) {
			cell.textLabel.text = NSLocalizedStringFromTable(@"Private", @"Name for private security level", kStringsTable);
		}
		
		if (indexPath.row == postOptionsController.accountStateInfo.newPostSecurity) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	} else {
		LJFriendGroup *friendGroup = [postOptionsController.account.friendGroups objectAtIndex:indexPath.row];
		cell.textLabel.text = friendGroup.name;
		cell.accessoryType = postOptionsController.accountStateInfo.newPostSecurity == LJEventSecurityCustom && [postOptionsController.accountStateInfo.newPostSelectedFriendGroups containsObject:[NSNumber numberWithUnsignedInteger:friendGroup.groupID]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

	NSMutableArray *selectedFriendGroups = [[postOptionsController.accountStateInfo.newPostSelectedFriendGroups mutableCopy] autorelease];
	
	if (indexPath.section == 0) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		if (postOptionsController.accountStateInfo.newPostSecurity == LJEventSecurityCustom) {
			for (int i = 0; i < [postOptionsController.account.friendGroups count] && [selectedFriendGroups count] > 0; i++) {
				LJFriendGroup *group = [postOptionsController.account.friendGroups objectAtIndex:i];
				NSNumber *groupID = [[NSNumber alloc] initWithUnsignedInteger:group.groupID];
				if ([selectedFriendGroups containsObject:groupID]) {
					[selectedFriendGroups removeObject:groupID];
					UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
					selectedCell.accessoryType = UITableViewCellAccessoryNone;
				}
				[groupID release];
			}
			[self.navigationItem setHidesBackButton:NO animated:YES];
		} else {
			UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:postOptionsController.accountStateInfo.newPostSecurity inSection:0]];
			selectedCell.accessoryType = UITableViewCellAccessoryNone;
		}
		postOptionsController.accountStateInfo.newPostSecurity = indexPath.row;
	} else {
		LJFriendGroup *group = [postOptionsController.account.friendGroups objectAtIndex:indexPath.row];
		NSNumber *groupID = [[NSNumber alloc] initWithUnsignedInteger:group.groupID];
		if (postOptionsController.accountStateInfo.newPostSecurity == LJEventSecurityCustom) {
			if ([selectedFriendGroups containsObject:groupID]) {
				[selectedFriendGroups removeObject:groupID];
				cell.accessoryType = UITableViewCellAccessoryNone;
				
				if ([selectedFriendGroups count] == 0) {
					[self.navigationItem setHidesBackButton:YES animated:YES];
				}
			} else {
				[selectedFriendGroups addObject:groupID];
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
				[self.navigationItem setHidesBackButton:NO animated:YES];
			}
		} else {
			UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:postOptionsController.accountStateInfo.newPostSecurity inSection:0]];
			selectedCell.accessoryType = UITableViewCellAccessoryNone;
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			[selectedFriendGroups addObject:groupID];
		}
		[groupID release];
		postOptionsController.accountStateInfo.newPostSecurity = LJEventSecurityCustom;
	}

	postOptionsController.accountStateInfo.newPostSelectedFriendGroups = selectedFriendGroups;
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)refresh {
	NSError *error;
	
	if ([client friendsForAccount:postOptionsController.account error:&error]) {		
		[accountManager storeAccounts];
		
		[self.tableView reloadData];
	} else {
		showErrorMessage(NSLocalizedString(@"Friend groups sync error", nil), decodeError([error code]));
	}
}

- (void)dealloc {
    [super dealloc];
}


@end

