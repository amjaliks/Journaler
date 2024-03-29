    //
//  TableViewController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.13.
//  Copyright 2010 A25. All rights reserved.
//

#import "TableViewController.h"


@implementation TableViewController

@synthesize tableView;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// table
	if (!tableView) {
		tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
		tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		tableView.delegate = self;
		tableView.dataSource = self;
		[self.view addSubview:tableView];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:animated];
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	self.editing = YES;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	self.editing = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}


@end
