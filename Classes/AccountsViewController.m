//
//  AccountsViewController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.01.
//  Copyright 2009 A25. All rights reserved.
//

#import "AccountsViewController.h"
#import "LiveJournal.h"
#import "Model.h"
#import "JournalerAppDelegate.h"

@implementation AccountsViewController


@synthesize editAccountViewController;
@synthesize accountViewController;

@synthesize table;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
	accounts = [self loadAccounts];
	if (!accounts) {
		accounts = [[NSMutableArray alloc] init];
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	if ([accounts count] == 0) {
		[self addAccount:nil];
	}
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
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [accounts count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *ident = @"account";
    LJAccount *account = [accounts objectAtIndex:indexPath.row];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:account.title];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.text = account.user;
		cell.detailTextLabel.text = account.server;
	}
    
    // Set up the cell...
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	selectedAccount = [accounts objectAtIndex:indexPath.row];
	if (tableView.editing) {
		selectedAccountTitle = [selectedAccount.title retain];
		[self presentModalViewController:editAccountViewController animated:YES];
	} else {
		[self.navigationController pushViewController:accountViewController animated:YES];
	}
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		LJAccount *account = [accounts objectAtIndex:indexPath.row];
		
		Model *model = ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate]).model;
		[model deleteAllPostsForAccount:account.title];
		[model saveAll];
		
		[accounts removeObject:account];
		[self saveAccounts];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		
		if ([accounts count] == 0) {
			[self addAccount:nil];
		}		
    }   
   // else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    //}   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	LJAccount *account = [[accounts objectAtIndex:fromIndexPath.row] retain];
	[accounts removeObjectAtIndex:fromIndexPath.row];
	[accounts insertObject:account atIndex:toIndexPath.row];
	[account release];
	
	[self saveAccounts];
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


- (void)dealloc {
    [super dealloc];
	[accounts dealloc];
}

- (NSMutableArray *) loadAccounts {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];
	path = [path stringByAppendingPathComponent:@"accounts.bin"];
	NSMutableArray *restoredAccounts = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	return [restoredAccounts retain];
}

- (void) saveAccounts {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];
	path = [path stringByAppendingPathComponent:@"accounts.bin"];
	[NSKeyedArchiver archiveRootObject:accounts toFile:path];
}

// Parāda konta parametrus
- (IBAction) addAccount:(id)sender {
	selectedAccount = nil;
	[self presentModalViewController:editAccountViewController animated:YES];
}

- (void)accountEditorController:(AccountEditorController *)controller didFinishedEditingAccount:(LJAccount *)account {
	if (selectedAccount) {
		NSUInteger index = [accounts indexOfObject:selectedAccount];
		[accounts removeObjectAtIndex:index];
		[accounts insertObject:account atIndex:index];
		
		if (![selectedAccountTitle isEqualToString:account.title]) {
			Model *model = ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate]).model;
			[model deleteAllPostsForAccount:selectedAccountTitle];
			[model saveAll];
		}
		[selectedAccountTitle release];		
	} else {
		[accounts addObject:account];
		selectedAccount = account;
		if (table.editing) {
			[self setEditing:NO];
			//[self.navigationItem.rightBarButtonItem select:nil];
			//[self.navigationItem.leftBarButtonItem = [UIBarButtonItem alloc]
		}
		[self.navigationController pushViewController:accountViewController animated:YES];			
	}
	[self saveAccounts];
	[table reloadData];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)accountEditorControllerDidCancel:(AccountEditorController *)controller {
	[self dismissModalViewControllerAnimated:YES];
}

- (LJAccount *)selectedAccountForAccountEditorController:(AccountEditorController *)controller {
	return selectedAccount;
}

- (LJAccount *)selectedAccountForAccountViewController:(AccountViewController *)accountViewController {
	return selectedAccount;
}

- (BOOL)isDublicateAccount:(NSString *)title {
	for (LJAccount *account in accounts) {
		if (selectedAccount != account && [account.title isEqualToString:title]) {
			return YES;
		}
	}
	return NO;
}

- (BOOL)hasNoAccounts {
	return [accounts count] == 0;
}

@end

