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
#import "AccountManager.h"
#import "BannerViewController.h"

@implementation AccountsViewController

@synthesize account;
@synthesize accountStateInfo;
@synthesize accountManager;

#pragma mark -
#pragma mark UIViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	if (self = [super initWithNibName:nibName bundle:nibBundle]) {
		accountManager = [AccountManager sharedManager];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	// Edit/Done poga
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
#ifndef LITEVERSION
	// konta pievienošanas poga
	self.navigationItem.rightBarButtonItem = addButton;
#endif
	
	// virsraksts
	self.navigationItem.title = @"Accounts";

	// poga "Settings" apakšējā rīkjoslā
	self.toolbarItems = [NSArray arrayWithObjects:settingsButton, nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	if ([accountManager.accounts count] == 0) {
		// ja kontu saraksts ir tukšs, atveram konta pievienošanas ekrānu
		[self addAccount:nil];
	} else {
		[self.navigationController setToolbarHidden:NO animated:YES];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	accountManager.stateInfo.openedAccountIndex = kStateInfoOpenedAccountIndexNone;

#ifdef LITEVERSION
	[[BannerViewController controller] addBannerToView:self.view resizeView:self.tableView];
#endif
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self.navigationController setToolbarHidden:YES animated:YES];
}

#ifndef LITEVERSION
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIDeviceOrientationPortrait || UIDeviceOrientationIsLandscape(interfaceOrientation);
}
#endif

- (void)viewDidUnload {
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = nil;
	self.toolbarItems = nil;
}


- (void)openAccountAtIndex:(NSInteger)index animated:(BOOL)animated {
	self.editing = NO;
	
	accountManager.stateInfo.openedAccountIndex = index;
	self.account = [accountManager.accounts objectAtIndex:index];
	
	self.navigationItem.backBarButtonItem = 
			[[[UIBarButtonItem alloc] initWithTitle:account.user style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];

	[self.navigationController pushViewController:accountTabBarController animated:animated];
}

#pragma mark -
#pragma mark Īpašības

- (void)setAccount:(LJAccount *)newAccount {
	account = newAccount;
	accountStateInfo = [accountManager.stateInfo stateInfoForAccount:newAccount];
}

#pragma mark Table view methods

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [accountManager.accounts count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *ident = @"account";
    LJAccount *tmpAccount = [accountManager.accounts objectAtIndex:indexPath.row];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

	cell.textLabel.text = tmpAccount.user;
	cell.detailTextLabel.text = tmpAccount.server;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	if (self.editing) {
		account = [accountManager.accounts objectAtIndex:indexPath.row];
		[self presentModalViewController:accountEditorNavigationController animated:YES];
	} else {
		[self openAccountAtIndex:indexPath.row animated:YES];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // nosakam dzēšamo ierakstu
		LJAccount *tmpAccount = [accountManager.accounts objectAtIndex:indexPath.row];
		
		// iedzēšam rakstus no keša
		Model *model = ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate]).model;
		[model deleteAllPostsForAccount:tmpAccount.title];
		[model saveAll];
		
		// dzēšam kontu
		[accountManager removeAccount:tmpAccount];
		
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		
		if (![accountManager.accounts count]) {
			[self addAccount:nil];
		}
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	[accountManager moveAccountFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Parāda konta parametrus
- (IBAction) addAccount:(id)sender {
	account = nil;
	[self presentModalViewController:accountEditorNavigationController animated:YES];
}

- (IBAction)showSettings:(id)sender {
	[self presentModalViewController:settingsNavigationController animated:YES];
}

- (void)didAddNewAccount {
	[self.tableView reloadData];
}

// atjauno saskarnes stāvokli
- (void)restoreState {
	// atvērtais konsts
	NSInteger openedAccountIndex = [AccountManager sharedManager].stateInfo.openedAccountIndex;
	
	// ja iepriekš bija atvērts konts, tad atveram to arī tagad
	if (openedAccountIndex != kStateInfoOpenedAccountIndexNone) {
		[self view];
		[self openAccountAtIndex:openedAccountIndex animated:NO];
	}
}

@end

