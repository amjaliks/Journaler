/*
 *  Macros.h
 *  Journaler
 *
 *  Created by Aleksejs Mjaliks on 09.11.23.
 *  Copyright 2009 A25. All rights reserved.
 *
 */

#define APP_CACHES_DIR [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
#define APP_IMAGE_CACHE_DIR [APP_CACHES_DIR stringByAppendingPathComponent:@"images"]
#define CACHED_IMAGE_PATH(hash) [APP_IMAGE_CACHE_DIR stringByAppendingPathComponent:hash]
