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
#import "NSStringMD5.h"
#import "LiveJournal.h"
#import "JournalerAppDelegate.h"
#import "Model.h"
#import "NetworkActivityIndicator.h"

#import "SynthesizeSingleton.h"

@implementation UserPicCache

- (id)init {
	if (self = [super init]) {
		dirPath = [[appCachesDir stringByAppendingPathComponent:@"images"] retain];
		if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
			[[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
		imageCache = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (NSString *)pathForCachedImage:(NSString *)hash {
	return [dirPath stringByAppendingPathComponent:hash];
}

- (void)downloadImageFromURL:(NSString *)URLString {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0f];
	
	[networkActivityIndicator show];
	
	NSURLResponse *res = nil;
	NSError *err = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
	
	if (!err) {
		NSString *hash = [URLString MD5Hash];
		[data writeToFile:[self pathForCachedImage:hash] atomically:NO];
		[imageCache setObject:[UIImage imageWithData:data] forKey:hash];
		[[NSNotificationCenter defaultCenter] postNotificationName:UserPicCacheDidDownloadUserPicNotification 
															object:self 
														  userInfo:[NSDictionary dictionaryWithObject:hash forKey:@"hash"]];
	}

	[networkActivityIndicator hide];

	[pool release];
}

- (UIImage *)imageForHash:(NSString *)hash URLString:(NSString *)URLString wait:(BOOL)wait {
	UIImage *image = [imageCache objectForKey:hash];
	if (image) {
		return image;
	}
	
	image = [UIImage imageWithContentsOfFile:[self pathForCachedImage:hash]];
	if (image) {
		[imageCache setObject:image forKey:hash];
		return image;
	}
	
	if (wait) {
		[self downloadImageFromURL:URLString];
	} else {
		[self performSelectorInBackground:@selector(downloadImageFromURL:) withObject:URLString];
	}
	
	return nil;
}

- (void)didReceiveMemoryWarning {
	[imageCache removeAllObjects];
}

SYNTHESIZE_SINGLETON_FOR_CLASS(UserPicCache)

@end
