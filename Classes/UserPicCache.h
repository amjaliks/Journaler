//
//  UserPicCache.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.18.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserPicCache : NSObject {
	NSMutableDictionary *dataCache;
	NSMutableDictionary *imageCache;
	NSMutableDictionary *base64DataCache;
	
	NSOperationQueue *queue;
}

- (NSData *) dataFromURL:(NSString *)url;
- (UIImage *) imageFromURL:(NSString *)url force:(BOOL)force;
- (NSString *) base64DataFromURL:(NSString *)url;
- (UIImage *) imageFromURL:(NSString *)url forTableView:(UITableView *)tableView;

- (UIImage *) imageFromURL:(NSString *)url hash:(NSString *)hash force:(BOOL)force;
- (UIImage *) imageFromURL:(NSString *)url hash:(NSString *)hash forTableView:(UITableView *)tableView;

- (void) cancelPendingDownloads;

- (NSString *) pathForCacheImage:(NSString *)hash;
- (UIImage *) ensureImageAvailabilityFromURL:(NSString *)url hash:(NSString *)hash;
- (NSData *) downloadDataFromURL:(NSString *)URL;

@end
