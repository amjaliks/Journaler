//
//  TagListController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 23.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchableListController.h"

@interface TagListController : SearchableListController {
	NSMutableSet *selectedTags;
}

@end
