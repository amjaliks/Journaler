//
//  MoodListController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 23.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchableListController.h"

@class LJMood;

@interface MoodListController : SearchableListController {
	LJMood *selectedMood;
	UITableViewCell *selectedCell;
}

@end
