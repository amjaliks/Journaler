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
#import "TagsCellView.h"
#import "TagListController.h"
#import "PicKeywordListController.h"

// šūnu veidi
enum {
	SimpleCell,
	TagsCell,
	SwitchCell
};

// šūnu veidu ID
NSString *cellIds[] = { 
	@"SimpleCell",
	@"TagsCell",
	@"SwitchCell"
};

// skatu tagi
enum {
	SwitchTag = 1
};

// sekcijas
enum {
	SectionBasic, // raksta pamatdati
#ifdef BETA
	SectionAdditional, // papildus dati par rakstu
#endif
	SectionPromote // promote
	
};

// pamatdati
enum {
	SectionBasicRowJournal,
	SectionBasicRowSecurity
};

enum {
	SectionAdditionalRowPicture,
	SectionAdditionalRowTags
};

enum {
	SecrionPromoteRowPromote
};

@implementation PostOptionsController

@synthesize account;
@synthesize dataSource;
@synthesize journal;
@synthesize security;
@synthesize selectedFriendGroups;
@synthesize picKeyword;
@synthesize tags;
@synthesize promote;

- (id)initWithAccount:(LJAccount *)newAccount {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		account = newAccount;
		
		journal = [account.user retain];
		security = PostSecurityPublic;
		selectedFriendGroups = [[NSMutableArray alloc] init];
		
		picKeyword = [[[AccountManager sharedManager] valueForAccount:account.title forKey:kStateInfoNewPostPicKeyword] retain];
		tags = [[[AccountManager sharedManager] valueForAccount:account.title forKey:kStateInfoNewPostTags] retain];
		
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
	
	self.navigationItem.title = NSLocalizedString(@"Options", nil);

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.leftBarButtonItem = doneButton;
	[doneButton release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView reloadData];
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
	[super viewDidUnload];
	
	self.navigationItem.leftBarButtonItem = nil;
	
	[journal release];
}


- (void)done {
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#ifdef BETA

#ifndef LITEVERSION
    return 3;
#else
	return 2;
#endif
	
#else // BETA
	
#ifndef LITEVERSION
    return 2;
#else
	return 1;
#endif
	
#endif // BETA
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) return 2;
#ifdef BETA
	if (section == 1) return 2;
#endif
	return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// nosak šūnas veidu
	NSUInteger cellKind;
	if (indexPath.section == SectionBasic) {
		if (indexPath.row == SectionBasicRowJournal) { cellKind = SimpleCell; }
		else if (indexPath.row == SectionBasicRowSecurity) { cellKind = SimpleCell; };
#ifdef BETA
	} else if (indexPath.section == SectionAdditional) {
		if (indexPath.row == SectionAdditionalRowPicture) { cellKind = SimpleCell; }
		else if (indexPath.row == SectionAdditionalRowTags) { cellKind = TagsCell; };
#endif // BETA
	} else if (indexPath.section == SectionPromote) {
		if (indexPath.row == 0) { cellKind = SwitchCell; };
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIds[cellKind]];
	
	if (!cell) {
		// ja nav atrasta piemērota šūna, izveidojam tādu
		if (cellKind == SimpleCell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIds[SimpleCell]];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		} else if (cellKind == TagsCell) {
			cell = [[TagsCellView alloc] initWithReuseIdentifier:cellIds[TagsCell]];
		} else if (cellKind == SwitchCell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIds[SwitchCell]];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UISwitch *cellSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(206, 9, 94, 26)];
			cellSwitch.tag = SwitchTag;
			cellSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
			[cell addSubview:cellSwitch];
			
			[cellSwitch release];
		}
	}
    
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			cell.textLabel.text = NSLocalizedString(@"Journal", nil);
			cell.detailTextLabel.text = journal;
		} else if (indexPath.row == 1) {
			cell.textLabel.text = NSLocalizedString(@"Security", nil);
			if (security == PostSecurityPublic) {
				cell.detailTextLabel.text = NSLocalizedString(@"Public", nil);
			} else if (security == PostSecurityFriends) {
				cell.detailTextLabel.text = NSLocalizedString(@"Friends only", nil);
			} else if (security == PostSecurityPrivate) {
				cell.detailTextLabel.text = NSLocalizedString(@"Private", nil);
			} else {
				cell.detailTextLabel.text = NSLocalizedString(@"Custom", nil);
			}
		}
#ifdef BETA
	} else if (indexPath.section == SectionAdditional) {
		if (indexPath.row == SectionAdditionalRowPicture) {
			cell.textLabel.text = NSLocalizedString(@"Userpic", nil);
			cell.detailTextLabel.text = picKeyword ? picKeyword : NSLocalizedString(@"Default", nil);
		} else if (indexPath.row == SectionAdditionalRowTags) {
			cell.textLabel.text = NSLocalizedString(@"Tags", nil);
			[(TagsCellView *)cell setTags:tags];
			[(TagsCellView *)cell setTarget:self action:@selector(tagsChanged:)];
		}
#endif // BETA
	} else if (indexPath.section == SectionPromote) {
		cell.textLabel.text = NSLocalizedString(@"Promote Journaler", nil);
		UISwitch *cellSwitch = (UISwitch *)[cell viewWithTag:SwitchTag];
		cellSwitch.on = promote;
		
		[cellSwitch removeTarget:self action:nil forControlEvents:UIControlEventValueChanged];
		[cellSwitch addTarget:self action:@selector(promoteChanged:) forControlEvents:UIControlEventValueChanged];
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionBasic) {
		if (indexPath.row == SectionBasicRowJournal) {
			PostJournalController *postJournalController = [[PostJournalController alloc] initWithPostOptionsController:self];
			[self.navigationController pushViewController:postJournalController animated:YES];
			[postJournalController release];
		} else { 
			PostSecurityController *postSecurityController = [[PostSecurityController alloc] initWithPostOptionsController:self];
			[self.navigationController pushViewController:postSecurityController animated:YES];
			[postSecurityController release];
		}
	} else if (indexPath.section == SectionAdditional) {
		if (indexPath.row == SectionAdditionalRowPicture) {
			PicKeywordListController *picKeywordListController = [[PicKeywordListController alloc] initWithPostOptionsController:self];
			[self.navigationController pushViewController:picKeywordListController animated:YES];
			[picKeywordListController release];
		}
	}
}

#ifdef BETA
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == SectionAdditional && indexPath.row == SectionAdditionalRowTags) {
		// nolasam tagus
		[self tagsChanged:[tableView cellForRowAtIndexPath:indexPath]];

		// atveram tagu sarakstu
		TagListController *tagListController = [[TagListController alloc] initWithPostOptionsController:self];
		[self.navigationController pushViewController:tagListController animated:YES];
		[tagListController release];
	}
}
#endif

- (void)dealloc {
	[selectedFriendGroups release];
	[tags release];
	
    [super dealloc];
}

- (void)tagsChanged:(id)sender {
	self.tags = ((TagsCellView *)sender).tags;
}

- (void)promoteChanged:(id)sender {
	promote = ((UISwitch *)sender).on;
	[[AccountManager sharedManager] setBoolValue:promote forAccount:account.title forKey:kStateInfoNewPostPromote];
}

- (void)setPicKeyword:(NSString *)newPicKeyword {
	if (newPicKeyword != picKeyword) {
		[picKeyword release];
		picKeyword = [newPicKeyword retain];
		
		[[AccountManager sharedManager] setValue:picKeyword forAccount:account.title forKey:kStateInfoNewPostPicKeyword];
	}
}

- (void)setTags:(NSArray *)newTags {
	if (newTags != tags) {
		[tags release];
		tags = [newTags retain];

		[[AccountManager sharedManager] setValue:tags forAccount:account.title forKey:kStateInfoNewPostTags];
	}
}

@end

