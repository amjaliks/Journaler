//
//  DelayedUserPicLoader.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.24.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserPicCache;

@interface DelayedUserPicLoader : NSOperation {
	NSString *url;
	NSString *hash;
	UITableView *tableView;
	UserPicCache *userPicCache;
}

- (id) initWithUserPicCache:(UserPicCache *)userPicCache URL:(NSString *)url tableView:(UITableView *)tableView;
- (id) initWithUserPicCache:(UserPicCache *)userPicCache URL:(NSString *)url hash:(NSString *)hash tableView:(UITableView *)tableView;

@end
