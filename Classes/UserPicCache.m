//
//  UserPicCache.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.18.
//  Copyright 2009 A25. All rights reserved.
//

#import "UserPicCache.h"
#import "NSStringAdditions.h"

@implementation UserPicCache

- (id) init {
	if (self = [super init]) {
		dataCache = [[NSMutableDictionary alloc] init];
		imageCache = [[NSMutableDictionary alloc] init];
		base64DataCache = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
	[dataCache release];
	[imageCache release];
	[base64DataCache release];
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

- (UIImage *) imageFromURL:(NSString *)url {
	UIImage *image = [imageCache valueForKey:url];
	if (image) {
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

@end
