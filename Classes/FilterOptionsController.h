//
//  FilterOptionsController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.05.03.
//  Copyright 2010 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FriendsPageController;

@interface FilterOptionsController : UITableViewController {
	FriendsPageController *friendsPageController;
}

-(id)initWithFriendsPageController:(FriendsPageController *)friendsPageController;
-(void)done:(id)sender;

@end
