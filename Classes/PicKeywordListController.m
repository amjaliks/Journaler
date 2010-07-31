//
//  PicKeywordListController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 23.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import "PicKeywordListController.h"

#import "PostOptionsController.h"
#import "LiveJournal.h"
#import "AccountManager.h"
#import "ErrorHandler.h"

@implementation PicKeywordListController

- (id)initWithPostOptionsController:(PostOptionsController *)newPostOptionsController {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		postOptionsController = newPostOptionsController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedString(@"Userpic", nil);
	
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
	return [postOptionsController.account.picKeywords count] > 0 ? 2 : 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return section == 0 ? 1 : [postOptionsController.account.picKeywords count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return section == 0 ? NSLocalizedString(@"Default", nil) : NSLocalizedString(@"Keywords", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
    if (indexPath.section == 0) {
		cell.textLabel.text = NSLocalizedString(@"Default", nil);
		
		if (!postOptionsController.picKeyword) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			selectedCell = cell;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	} else {
		cell.textLabel.text = [postOptionsController.account.picKeywords objectAtIndex:indexPath.row];
		
		if ([cell.textLabel.text isEqualToString:postOptionsController.picKeyword]) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			selectedCell = cell;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
	
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	if (indexPath.section == 0) {
		postOptionsController.picKeyword = nil;
		//[accountManager setValue:nil forAccount:postOptionsController.account.title forKey:kStateInfoNewPostPicKeyword];
	} else {
		postOptionsController.picKeyword = cell.textLabel.text;
		//[accountManager setValue:cell.textLabel.text forAccount:postOptionsController.account.title forKey:kStateInfoNewPostPicKeyword];
	}
	
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
	if ([client loginForAccount:postOptionsController.account error:&error]) {
		[accountManager storeAccounts];
		
		if (postOptionsController.picKeyword && ![postOptionsController.account.tags containsObject:postOptionsController.picKeyword]) {
			postOptionsController.picKeyword = nil;
		}
		
		[self.tableView reloadData];	
	} else {
		showErrorMessage(NSLocalizedString(@"Picture keyword list sync error", nil), decodeError([error code]));
	}
}


@end
