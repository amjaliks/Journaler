//
//  TableViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.13.
//  Copyright 2010 A25. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *_tableView;
}

@property (readonly) UITableView *tableView;

@end
