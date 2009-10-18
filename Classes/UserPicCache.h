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
}

- (NSData *) dataFromURL:(NSString *)url;
- (UIImage *) imageFromURL:(NSString *)url;
- (NSString *) base64DataFromURL:(NSString *)url;

@end
