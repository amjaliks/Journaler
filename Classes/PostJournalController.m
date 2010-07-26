//
//  PostJournalController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.12.01.
//  Copyright 2009 A25. All rights reserved.
//

#import "PostJournalController.h"

#import "JournalerAppDelegate.h"
#import "PostOptionsController.h"
#import "LiveJournal.h"
#import "AccountManager.h"
#import "ErrorHandling.h"

#define kStringsTable @"PostOptions"

@implementation PostJournalController


- (id)initWithPostOptionsController:(PostOptionsController *)newPostOptionsController {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		postOptionsController = newPostOptionsController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedString(@"Journal", nil);
	
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

#ifndef LITEVERSION
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIDeviceOrientationPortrait || UIDeviceOrientationIsLandscape(interfaceOrientation);
}
#endif

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// ja pie ir lietotājam ir pieeja kopienām, tad tabulai būs 2 sekcijas
    return [postOptionsController.account.communities count] > 0 ? 2 : 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// 0. sekcijā (savs žurnāls) vienmēr būs 1 ieraksts
	// 1. sekcijā (kopienas) rindu skaits atkarīgs no lietotā kopienu skaita
	return section == 0 ? 1 : [postOptionsController.account.communities count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return section == 0 ? NSLocalizedStringFromTable(@"My Journal", @"Section name for an user journal", kStringsTable) : NSLocalizedStringFromTable(@"Communities", @"Section name for communities", kStringsTable);
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    if (indexPath.section == 0) {
		cell.imageView.image = [UIImage imageNamed:@"user.png"];
		cell.textLabel.text = postOptionsController.account.user;
	} else {
		cell.imageView.image = [UIImage imageNamed:@"community.png"];
		cell.textLabel.text = [postOptionsController.account.communities objectAtIndex:indexPath.row];
	}
	
	if ([cell.textLabel.text isEqualToString:postOptionsController.journal]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		selectedCell = cell;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	postOptionsController.journal = cell.textLabel.text;
	[[AccountManager sharedManager].stateInfo stateInfoForAccount:postOptionsController.account].newPostJournal = cell.textLabel.text;
	
	selectedCell.accessoryType = UITableViewCellAccessoryNone;
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	selectedCell = cell;
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)dealloc {
    [super dealloc];
}


- (void)refresh {
	NSError *error;
	if ([[LJManager defaultManager] loginForAccount:postOptionsController.account error:&error]) {
		[[AccountManager sharedManager] storeAccounts];
		
		if (![postOptionsController.account.communities containsObject:postOptionsController.journal]) {
			postOptionsController.journal = postOptionsController.account.user;
		}
		
		[self.tableView reloadData];	
	} else {
		showErrorMessage(NSLocalizedStringFromTable(@"Journal list sync error", @"Title for journal list sync error messages", kErrorStringsTable), decodeError([error code]));
	}
}

@end

