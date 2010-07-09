//
//  HouseAdManager.m
//  Journaler
//
//  Created by Natālija Dudareva on 7/9/10.
//  Copyright 2010 A25. All rights reserved.
//

#import "HouseAdManager.h"
#import "NSStringMD5.h"

HouseAdManager *houseAdManager;

@implementation HouseAdManager

#pragma mark -
#pragma mark Reklāmas ielāde

- (void)loadAd {
	
}

- (UIImage *) ensureFileAvailabilityFromURL:(NSString *)URL hash:(NSString *)hash {
	// ja hešs nav tad, aprēķinam
	if (!hash) {
		hash = [URL MD5Hash];
	}
	
	@synchronized (dataCache) {
//		NSString *path = [self pathForCacheImage:hash];
//		NSFileManager *mng = [NSFileManager defaultManager];
//		if (![mng fileExistsAtPath:path]) {
//			NSData *data = [self downloadDataFromURL:URL];
//			if (data) {
//				[data writeToFile:path atomically:YES];
//			}
//		}
	}
	
//	@synchronized (imageCache) {
//		UIImage *image = [imageCache objectForKey:hash];
//		if (image) {
//			return image;
//		}
//		
//		NSString *path = [self pathForCacheImage:hash];
//		NSFileManager *mng = [NSFileManager defaultManager];
//		if (![mng fileExistsAtPath:path]) {
//			NSData *data = [self downloadDataFromURL:URL];
//			if (data) {
//				[data writeToFile:path atomically:YES];
//			}
//		}
//		image = [UIImage imageWithContentsOfFile:path];
//		[imageCache setObject:image forKey:hash];
//		return image;		
//	}
	return nil;
}

//- (NSString *) pathForCacheImage:(NSString *)hash {
//	NSString *path = APP_CACHES_DIR;
//	
//	path = [path stringByAppendingPathComponent:@"images"];
//	NSFileManager *mng = [NSFileManager defaultManager];
//	if (![mng fileExistsAtPath:path]) {
//		[mng createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
//	}
//	
//	path = [path stringByAppendingPathComponent:hash];
//	return path;
//}

- (NSData *) downloadDataFromURL:(NSString *)URL {
	NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:URL] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
	
	NSURLResponse *res = nil;
	NSError *err = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
	
	if (err) {
		return nil;
	} else {
		return data;
	}
}


#pragma mark -
#pragma mark Singleton metodes

+ (HouseAdManager *)houseAdManager {
	@synchronized (self) {
		if (houseAdManager == nil) {
			houseAdManager = [[super allocWithZone:nil] init];
		}
	}
	return houseAdManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self houseAdManager] retain];
}

- (id)init {
	self = [super init];
	if (self != nil) {}
	return self;
}


- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
