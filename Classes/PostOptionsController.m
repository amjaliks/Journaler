//
//  PostOptionsController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.30.
//  Copyright 2009 A25. All rights reserved.
//

#import "PostOptionsController.h"

#import "Macros.h"
#import "LiveJournal.h"
#import "PostJournalController.h"
#import "PostSecurityController.h"
#import "AccountManager.h"

#define kStringsTable @"PostOptions"

@implementation PostOptionsController

@synthesize account;
@synthesize dataSource;
@synthesize journal;
@synthesize security;
@synthesize selectedFriendGroups;

- (id)initWithAccount:(LJAccount *)newAccount {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		account = newAccount;
		
		journal = [account.user retain];
		security = PostSecurityPublic;
		selectedFriendGroups = [[NSMutableArray alloc] init];
		
#ifdef LITEVERSION
		promote = YES;
#else
		promote = [[AccountManager sharedManager] boolValueForAccount:account.title forKey:kStateInfoNewPostPromote defaultValue:YES];
#endif
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = @"Options";

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.leftBarButtonItem = doneButton;
	[doneButton release];
	
	journalCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"JournalCell"];
	journalCell.textLabel.text = @"Journal";
	journalCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	securityCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SecurityCell"];
	securityCell.textLabel.text = @"Security";
	securityCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	promoteCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PromoteCell"];
	promoteCell.textLabel.text = @"Promote Journaler";
	promoteCell.selectionStyle = UITableViewCellSelectionStyleNone;
	promoteSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(206, 9, 94, 26)];
	promoteSwitch.on = promote;
	[promoteSwitch addTarget:self action:@selector(promoteChanged) forControlEvents:UIControlEventValueChanged];
	[promoteCell addSubview:promoteSwitch];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	self.navigationItem.leftBarButtonItem = nil;
	
	[journal release];
	
	[journalCell release];
	[securityCell release];
	[promoteCell release];
	[promoteSwitch release];
}


- (void)done {
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#ifndef LITEVERSION
    return 2;
#else
	return 1;
#endif
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 2 : 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			journalCell.detailTextLabel.text = journal;
			return journalCell;
		} else if (indexPath.row == 1) {
			if (security == PostSecurityPublic) {
				securityCell.detailTextLabel.text = NSLocalizedStringFromTable(@"Public", @"Name for public security level", kStringsTable);
			} else if (security == PostSecurityFriends) {
				securityCell.detailTextLabel.text = NSLocalizedStringFromTable(@"Friends only", @"Name for friends-only security level", kStringsTable);
			} else if (security == PostSecurityPrivate) {
				securityCell.detailTextLabel.text = NSLocalizedStringFromTable(@"Private", @"Name for private security level", kStringsTable);
			} else {
				securityCell.detailTextLabel.text = NSLocalizedStringFromTable(@"Custom", @"Name for custom security level", kStringsTable);
			}
			return securityCell;
		}
	} else if (indexPath.section == 1) {
		return promoteCell;
	}
	
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			PostJournalController *postJournalController = [[PostJournalController alloc] initWithPostOptionsController:self];
			[self.navigationController pushViewController:postJournalController animated:YES];
			[postJournalController release];
		} else { 
			PostSecurityController *postSecurityController = [[PostSecurityController alloc] initWithPostOptionsController:self];
			[self.navigationController pushViewController:postSecurityController animated:YES];
			[postSecurityController release];
		}
	}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[selectedFriendGroups release];
    [super dealloc];
}

- (void)promoteChanged {
	promote = promoteSwitch.on;
	[[AccountManager sharedManager] setBoolValue:promote forAccount:account.title forKey:kStateInfoNewPostPromote];
}

#pragma mark Iestatījumu nolasīšana

- (BOOL)promote {
	if (promoteSwitch) {
		return promoteSwitch.on; 
	} else {
		return promote;
	}
}

@end

