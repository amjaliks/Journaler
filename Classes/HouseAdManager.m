//
//  HouseAdManager.m
//  Journaler
//
//  Created by Natālija Dudareva on 7/9/10.
//  Copyright 2010 A25. All rights reserved.
//

#import "HouseAdManager.h"
#import "Macros.h"
#import "NSStringMD5.h"

HouseAdManager *houseAdManager;

@implementation HouseAdManager

#pragma mark -
#pragma mark Reklāmas ielāde

- (void)loadAd {
	NSData *data = [self readFile:@"test.plist" URL:@"http:ndu/~ndudareva/"];
	if (data) {
		NSPropertyListFormat format;
		NSString *error = nil;
		
		NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization 
											  propertyListFromData:data 
											  mutabilityOption:NSPropertyListMutableContainersAndLeaves 
											  format:&format 
											  errorDescription:&error];
		if (temp) {
//			NSString *url = [temp objectForKey:@"string"];
//			NSLog(@"URL: %@", url);
		}
		
		
		NSLog(@"File downloaded");
		NSLog(@"Log: %@", data);
	} else {
		NSLog(@"Failed");
	}

}

- (NSData *)readFile:(NSString *)fileName URL:(NSString *)URL {
	NSFileManager *mng = [NSFileManager defaultManager];
	NSString *dataPath = [dataDirPath stringByAppendingPathComponent:fileName];
	if (![mng fileExistsAtPath:dataPath]) {
		NSData *file = [self downloadDataFromURL:[URL stringByAppendingPathComponent:fileName]];
		if (file) {
			[file writeToFile:dataPath atomically:YES];
		}
	}
	return [NSData dataWithContentsOfFile:dataPath];
}

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
	
	if (self != nil) {
		// 
		dataDirPath = [[APP_CACHES_DIR stringByAppendingPathComponent:@"houseAds"] retain];
		NSFileManager *mng = [NSFileManager defaultManager];
		if (![mng fileExistsAtPath:dataDirPath]) {
			[mng createDirectoryAtPath:dataDirPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
	}
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

- (void)dealloc {
	[dataDirPath release];
	
	[super dealloc];
}

@end
