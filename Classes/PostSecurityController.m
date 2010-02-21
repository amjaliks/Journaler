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
#import "LJManager.h"

#import "ErrorHandling.h"

#define kStringsTable @"PostOptions"

@implementation PostSecurityController

- (id)initWithPostOptionsController:(PostOptionsController *)newPostOptionsController {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
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
	return section == 0 ? NSLocalizedStringFromTable(@"Security level", @"Section name for default security levesls", kStringsTable) : NSLocalizedStringFromTable(@"Custom", @"Section name for custom security level", kStringsTable);
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
		
		if (indexPath.row == postOptionsController.security) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			selectedCell = cell;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	} else {
		cell.textLabel.text = [[postOptionsController.account.friendGroups objectAtIndex:indexPath.row] name];
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	postOptionsController.security = indexPath.row;
	[[AccountManager sharedManager] setUnsignedIntegerValue:indexPath.row forAccount:postOptionsController.account.title forKey:kStateInfoNewPostSecurity];
	
	selectedCell.accessoryType = UITableViewCellAccessoryNone;
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	selectedCell = cell;
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)refresh {
	LJManager *manager = [LJManager defaultManager];
	NSError *error;
	
	NSArray *friendGroups = [manager friendGroupsForAccount:postOptionsController.account error:&error];
	if (friendGroups) {		
		postOptionsController.account.friendGroups = friendGroups;
		[[AccountManager sharedManager] storeAccounts];
		
		[self.tableView reloadData];
	} else {
		showErrorMessage(NSLocalizedStringFromTable(@"Friend groups sync error", @"Title for friend groups sync error messages", kErrorStringsTable), decodeError([error code]));
	}
}

- (void)dealloc {
    [super dealloc];
}


@end

