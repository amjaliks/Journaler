//
//  DelayedUserPicLoader.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.24.
//  Copyright 2009 A25. All rights reserved.
//

#import "DelayedUserPicLoader.h"
#import "UserPicCache.h"
#import "PostSummaryCell.h"
#import "Model.h"

@implementation DelayedUserPicLoader

- (id) initWithUserPicCache:(UserPicCache *)_userPicCache URL:(NSString *)_url tableView:(UITableView *)_tableView {
	self = [super init];
	if (self != nil) {
		userPicCache = _userPicCache;
		url = _url;
		hash = nil;
		tableView = _tableView;
	}
	return self;
}

- (id) initWithUserPicCache:(UserPicCache *)_userPicCache URL:(NSString *)_url hash:(NSString *)_hash tableView:(UITableView *)_tableView {
	self = [super init];
	if (self != nil) {
		userPicCache = _userPicCache;
		url = _url;
		hash = _hash;
		tableView = _tableView;
	}
	return self;
}


- (void)main {
	UIImage *image = [userPicCache imageFromURL:url hash:hash force:YES];
	//[userPicCache base64DataFromURL:url];
	
#ifdef DEBUG
	NSLog(@"userpic loaded %@", url);
#endif
	
	NSArray *cells = [tableView visibleCells];
	for (PostSummaryCell *cell in cells) {
		if (cell.missingUserPic && [url isEqualToString:cell.post.userPicURL]) {
			[cell setUserPic:image];
		}
	}
}

@end
