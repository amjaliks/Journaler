//
//  AccountsViewController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.01.
//  Copyright 2009 A25. All rights reserved.
//

#import "AccountsViewController.h"

#import "AccountTabBarController.h"
#import "LiveJournal.h"
#import "Model.h"
#import "JournalerAppDelegate.h"
#import "ALReporter.h"
#import "SettingsController.h"

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

    editButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleEdit)];
    self.navigationItem.leftBarButtonItem = editButtonItem;
	
	NSArray *loadedAccounts = [APP_DELEGATE loadAccounts];
	if (loadedAccounts) {
		accounts = [loadedAccounts mutableCopy];
	} else {
		accounts = [[NSMutableArray alloc] init];
	}
	
	cacheTabBarControllers = [[NSMutableDictionary alloc] initWithCapacity:[accounts count]];
	
	// konta pievienošanas poga
	UIBarButtonItem *addAccountButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAccount:)];
	self.navigationItem.rightBarButtonItem = addAccountButton;
	[addAccountButton release];
	
	// virsraksts
	self.navigationItem.title = @"Accounts";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	if ([accounts count] == 0) {
		[self addAccount:nil];
	}
	[table deselectRowAtIndexPath:[table indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[editButtonItem release];
}

- (void)openAccount:(LJAccount *)account {
	// ja nav labošanas režīms, tad veram vaļā konta skatījumu
	AccountTabBarController *tabBarController = [[cacheTabBarControllers objectForKey:account.title] retain];
	if (!tabBarController) {
		// ja skatījums nav atrasts, tad tādu izveidojam
		tabBarController = [[AccountTabBarController alloc] initWithAccount:account];
		[cacheTabBarControllers setObject:tabBarController forKey:account.title];
	}
	
	[self.navigationController pushViewController:tabBarController animated:YES];
	[tabBarController release];
}

#pragma mark Table view methods

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
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident];
	}

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.text = account.user;
	cell.detailTextLabel.text = account.server;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	selectedAccount = [accounts objectAtIndex:indexPath.row];
	if (tableView.editing) {
		selectedAccountTitle = [selectedAccount.title retain];
		[self presentModalViewController:editAccountViewController animated:YES];
	} else {
		[self openAccount:selectedAccount];
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
        // nosakam dzēšamo ierakstu
		LJAccount *account = [accounts objectAtIndex:indexPath.row];
		
		// iedzēšam rakstus no keša
		Model *model = ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate]).model;
		[model deleteAllPostsForAccount:account.title];
		[model saveAll];
		
		// iztīram no keša konta "ekrānu"
		[cacheTabBarControllers removeObjectForKey:account.title];
		
		// izdzešam kontu un saglabājam
		[accounts removeObject:account];
		[self saveAccounts];
		
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		
		if ([accounts count] == 0) {
			[self addAccount:nil];
		} else {
			// nosūtam informāciju par kontiem
			[self sendReport];
		}
    }   
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

- (void)saveAccount:(LJAccount *)account {
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
		[self openAccount:account];
	}
	[self saveAccounts];
	[table reloadData];
		
	[self dismissModalViewControllerAnimated:YES];
	
	// nosūtam informāciju par kontiem
	[self sendReport];
}

- (LJAccount *)selectedAccount {
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

- (void) sendReport {
	ALReporter *reporter = ((JournalerAppDelegate *)[UIApplication sharedApplication].delegate).reporter;
	[reporter setInteger:[accounts count] forProperty:@"account_count"];
	
	NSMutableSet *servers = [[NSMutableSet alloc] init];
	for (LJAccount *account in accounts) {
		[servers addObject:account.server];
	}
	[reporter setObject:servers forProperty:@"server"];
	[servers release];
}

- (void)saveState {
	for (LJAccount *account in accounts) {
		AccountTabBarController *accountTabBarController = [cacheTabBarControllers objectForKey:account.title];
		if (accountTabBarController) {
			[accountTabBarController saveState];
		}
	}
	
	[APP_DELEGATE saveAccounts:accounts];
}

- (void) toggleEdit {
	if (table.editing) {
		[table setEditing:NO animated:YES];
		editButtonItem.title = @"Edit";
		editButtonItem.style = UIBarButtonItemStyleBordered;
	} else {
		[table setEditing:YES animated:YES];
		editButtonItem.title = @"Done";
		editButtonItem.style = UIBarButtonItemStyleDone;
	}
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	editButtonItem.title = @"Done";
	editButtonItem.style = UIBarButtonItemStyleDone;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	editButtonItem.title = @"Edit";
	editButtonItem.style = UIBarButtonItemStyleBordered;
}

- (IBAction)showSettings {
	SettingsController *settings = [[SettingsController alloc] initWithNibName:@"SettingsController" bundle:nil];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settings];
	
	[self presentModalViewController:nav animated:YES];
	
	[nav release];
	[settings release];
}

@end

