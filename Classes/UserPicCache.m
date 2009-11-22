//
//  UserPicCache.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.18.
//  Copyright 2009 A25. All rights reserved.
//

#import "UserPicCache.h"
#import "NSStringAdditions.h"
#import "DelayedUserPicLoader.h"
#import "LiveJournal.h"
#import "JournalerAppDelegate.h"

@implementation UserPicCache

- (id) init {
	if (self = [super init]) {
		dataCache = [[NSMutableDictionary alloc] init];
		imageCache = [[NSMutableDictionary alloc] init];
		base64DataCache = [[NSMutableDictionary alloc] init];
		
		queue = [[NSOperationQueue alloc] init];
	}
	return self;
}

- (void) dealloc {
	[dataCache release];
	[imageCache release];
	[base64DataCache release];
	[queue release];
	[super dealloc];
}

- (NSData *) dataFromURL:(NSString *)url {
	NSData *data = [dataCache valueForKey:url];
	if (data) {
		return data;
	} else {
		NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
		
		NSURLResponse *res;
		NSError *err;
		NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
		
		[dataCache setValue:data forKey:url];
		return data;
	}
}

- (UIImage *) imageFromURL:(NSString *)url force:(BOOL)force {
	UIImage *image = [imageCache valueForKey:url];
	if (image || !force) {
		return image;
	} else {
		NSData *data = [self dataFromURL:url];
		
		image = [[UIImage alloc] initWithData:data];
		[imageCache setValue:image forKey:url];
		return image;
	}
}

- (NSString *) base64DataFromURL:(NSString *)url {
	NSString *base64Data = [base64DataCache valueForKey:url];
	if (base64Data) {
		return base64Data;
	} else {
		NSData *data = [self dataFromURL:url];
		
		base64Data = [NSString base64StringFromData:data length:[data length]];
		[base64DataCache setValue:base64Data forKey:url];
		return base64Data;
	}
}

- (UIImage *) imageFromURL:(NSString *)url forTableView:(UITableView *)tableView {
	UIImage *image = [imageCache valueForKey:url];
	if (image) {
		return image;
	} else {
		[queue addOperation:[[[DelayedUserPicLoader alloc] initWithUserPicCache:self URL:url tableView:tableView] autorelease]];
		return nil;
	}
}

- (void) cancelPendingDownloads {
	[queue cancelAllOperations];
}

- (UIImage *) imageFromURL:(NSString *)URL hash:(NSString *)hash force:(BOOL)force {
	// ja hešs nav tad, aprēķinam
	if (!hash) {
		hash = md5(URL);
	}
	
	UIImage *image = [imageCache objectForKey:hash];
	if (image) {
		return image;
	}
	
	NSString *path = [self pathForCacheImage:hash];
	
	if (force) {
		return [self ensureImageAvailabilityFromURL:URL hash:hash];
	} else {
		NSFileManager *mng = [NSFileManager defaultManager];
		if ([mng fileExistsAtPath:path]) {
			UIImage *image = [UIImage imageWithContentsOfFile:path];
			[imageCache setObject:image forKey:hash];
			return image;
		} else {
			return nil;
		}
	}
}

- (UIImage *) imageFromURL:(NSString *)URL hash:(NSString *)hash forTableView:(UITableView *)tableView {
	// ja hešs nav tad, aprēķinam
	if (!hash) {
		hash = md5(URL);
	}
	
	UIImage *image = [imageCache objectForKey:hash];
	if (image) {
		return image;
	} else {
		[queue addOperation:[[[DelayedUserPicLoader alloc] initWithUserPicCache:self URL:URL hash:hash tableView:tableView] autorelease]];
		return nil;
	}

//	NSString *path = [self pathForCacheImage:hash];
//	
//	NSFileManager *mng = [NSFileManager defaultManager];
//	if ([mng fileExistsAtPath:path]) {
//		UIImage *image = [UIImage imageWithContentsOfFile:path];
//		[imageCache setObject:image forKey:hash];
//		return image;
//	} else {
//		[queue addOperation:[[[DelayedUserPicLoader alloc] initWithUserPicCache:self URL:URL tableView:tableView] autorelease]];
//		return nil;
//	}
}

- (UIImage *) ensureImageAvailabilityFromURL:(NSString *)URL hash:(NSString *)hash {
	// ja hešs nav tad, aprēķinam
	if (!hash) {
		hash = md5(URL);
	}

	@synchronized (imageCache) {
		UIImage *image = [imageCache objectForKey:hash];
		if (image) {
			return image;
		}
		
		NSString *path = [self pathForCacheImage:hash];
		NSFileManager *mng = [NSFileManager defaultManager];
		if (![mng fileExistsAtPath:path]) {
			NSData *data = [self downloadDataFromURL:URL];
			if (data) {
				[data writeToFile:path atomically:YES];
			}
		}
		image = [UIImage imageWithContentsOfFile:path];
		[imageCache setObject:image forKey:hash];
		return image;		
	}
}

- (NSString *) pathForCacheImage:(NSString *)hash {
	NSString *path = APP_CACHES_DIR;
	
	path = [path stringByAppendingPathComponent:@"images"];
	NSFileManager *mng = [NSFileManager defaultManager];
	if (![mng fileExistsAtPath:path]) {
		[mng createDirectoryAtPath:path attributes:nil];
	}
	
	path = [path stringByAppendingPathComponent:hash];
	return path;
}

- (NSData *) downloadDataFromURL:(NSString *)URL {
	NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:URL] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
	
	NSURLResponse *res;
	NSError *err;
	NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
	
	if (err) {
		return nil;
	} else {
		return data;
	}
}

@end
