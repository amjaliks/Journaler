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

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return postOptionsController.account.communities ? 2 : 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return section == 0 ? 1 : [postOptionsController.account.communities count];
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
	
	selectedCell.accessoryType = UITableViewCellAccessoryNone;
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	selectedCell = cell;
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
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

