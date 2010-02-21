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
	
	self.navigationItem.title = @"Journal";
	
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
	// ja pie ir lietotājam ir pieeja kopienām, tad tabulai būs 2 sekcijas
    return postOptionsController.account.communities ? 2 : 1;
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
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	postOptionsController.journal = cell.textLabel.text;
	[[AccountManager sharedManager] setValue:cell.textLabel.text forAccount:postOptionsController.account.title forKey:kStateInfoNewPostJournal];
	
	selectedCell.accessoryType = UITableViewCellAccessoryNone;
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	selectedCell = cell;
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)dealloc {
    [super dealloc];
}


- (void)refresh {
	LJGetChallenge *req = [LJGetChallenge requestWithServer:postOptionsController.account.server];
	if ([req doRequest]) {
		LJLogin *login = [LJLogin requestWithServer:postOptionsController.account.server user:postOptionsController.account.user password:postOptionsController.account.password challenge:req.challenge];
		if ([login doRequest]) {
			if (login.usejournals) {
				postOptionsController.account.communities = login.usejournals;
			} else {
				postOptionsController.account.communities = [NSArray array];
			}
			[self.tableView reloadData];
			
			[[AccountManager sharedManager] storeAccounts];
		}
	}	
}

@end

