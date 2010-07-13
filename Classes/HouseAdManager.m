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
#import "HouseAdViewController.h"

#define kHouseAdInfoFileName @"houseadinfo.bin"

HouseAdManager *houseAdManager;

@implementation HouseAdManager

#pragma mark -
#pragma mark Reklāmas ielāde

- (void)loadAd {
	NSData *data = [self readFile:@"test.plist" URL:@"http:ndu/~ndudareva/test.plist"];
	if (data) {
		NSPropertyListFormat format;
		NSString *error = nil;

		NSString *url = [NSPropertyListSerialization 
						  propertyListFromData:data 
						  mutabilityOption:NSPropertyListImmutable 
						  format:&format 
						  errorDescription:&error];
		if (url) {
			NSData *file = [self readFile:@"banner.png" URL:url];
			image = [UIImage imageWithData:file];

			// tiks ielādēta informācija par reklāmu
		}
	}
}

- (void)showAd:(UINavigationController *)navigationController {
	if ([self prepareAd]) {
		// tiek parādīts logs ar reklāmu
		HouseAdViewController *houseAdViewController = [[HouseAdViewController alloc] initWithNibName:@"HouseAdViewController" bundle:nil];
		[navigationController presentModalViewController:houseAdViewController animated:NO];
		[houseAdViewController startShowing:image];
		[houseAdViewController release];
	}
}

- (BOOL)prepareAd {
	[self loadHouseAdInfo];
	
	return YES;
}

- (void)loadHouseAdInfo {
	NSString *path = [APP_CACHES_DIR stringByAppendingPathComponent:kHouseAdInfoFileName];
	houseAdInfo = [[NSKeyedUnarchiver unarchiveObjectWithFile:path] retain];
	
	if (!houseAdInfo) {
		houseAdInfo = [[NSMutableDictionary alloc] init];
	}
}

- (void)storeHouseAdInfo {
	NSString *path = [APP_CACHES_DIR stringByAppendingPathComponent:kHouseAdInfoFileName];
	[NSKeyedArchiver archiveRootObject:houseAdInfo toFile:path];
}

#pragma mark -
#pragma mark Failu lasīšana un ielāde

- (NSData *)readFile:(NSString *)fileName URL:(NSString *)URL {
	NSFileManager *mng = [NSFileManager defaultManager];
	NSString *dataPath = [dataDirPath stringByAppendingPathComponent:fileName];
	if (![mng fileExistsAtPath:dataPath]) {
		NSData *file = [self downloadDataFromURL:URL];
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
	[houseAdInfo release];
	[image release];
	
	[super dealloc];
}

@end
