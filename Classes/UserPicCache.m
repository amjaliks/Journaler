//
//  UserPicCache.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.18.
//  Copyright 2009 A25. All rights reserved.
//

#import "UserPicCache.h"
#import "Macros.h"
#import "NSStringAdditions.h"
#import "LiveJournal.h"
#import "JournalerAppDelegate.h"
#import "Model.h"
#import "NetworkActivityIndicator.h"

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
	return nil;

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
		return nil;

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
	return nil;
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
	
	[[NetworkActivityIndicator sharedInstance] show];
	
	NSURLResponse *res;
	NSError *err;
	NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];

	[[NetworkActivityIndicator sharedInstance] hide];

	if (err) {
		return nil;
	} else {
		return data;
	}
}

- (UIImage *)imageFromCacheForHash:(NSString *)hash {
	@synchronized (imageCache) {
		UIImage *image = [imageCache objectForKey:hash];
		if (image) {
			return image;
		}
		image = [UIImage imageWithContentsOfFile:[self pathForCacheImage:hash]];
		if (image) {
			[imageCache setObject:image forKey:hash];
			return image;
		}
	}
	return nil;
}

- (void)downloadUserPicForPost:(Post *)post {
	@synchronized (imageCache) {
		// pirms, ko lejuplādējam, pārliecinamies, ka bildes joprojām nav
		if (!post.userPic) {
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			
			// vispirms cenšamies vēlreiz bildi saņemt no keša
			UIImage *image = [self userPicForPost:post];
			
			if (image) {
				post.userPic = image;
				if (post.view) {
					[post.view setNeedsDisplay];
				}
			}
			
			[pool release];
		}
	}
}

- (UIImage *)userPicForPost:(Post *)post {
	@synchronized(imageCache) {
		// vispirms cenšamies bildi saņemt no keša
		UIImage *image = [self imageFromCacheForHash:post.userPicURLHash];
		if (!image) {
			// bildes kešā nav, tad to lejuplādējam
			NSData *data = [self downloadDataFromURL:post.userPicURL];
			if (data) {
				// ja lejuplādē veiksmīga, tad to datus saglabājam
				[data writeToFile:[self pathForCacheImage:post.userPicURLHash] atomically:NO];
				image = [UIImage imageWithData:data];
				[imageCache setObject:image forKey:post.userPicURLHash];
			}
		}
		return image;
	}
	return nil;
}

@end
