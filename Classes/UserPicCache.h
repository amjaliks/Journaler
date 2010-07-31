//
//  UserPicCache.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.18.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#define userPicCache [UserPicCache sharedUserPicCache]

#define UserPicCacheDidDownloadUserPicNotification @"UserPicCacheDidDownloadUserPicNotification"

@class Post;

@interface UserPicCache : NSObject {
	NSString *dirPath;
	NSMutableDictionary *imageCache;
}

+ (UserPicCache *)sharedUserPicCache;

- (NSString *)pathForCachedImage:(NSString *)hash;
- (UIImage *)imageForHash:(NSString *)hash URLString:(NSString *)URLString wait:(BOOL)wait;
- (void)downloadImageFromURL:(NSString *)URLString;

- (void)didReceiveMemoryWarning;

@end
