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

#import "ALDeviceInfo.h"

#define kHouseAdInfoFileName @"houseadinfo.bin"
#define bannerFileName @"banner.png"

HouseAdManager *houseAdManager;

@implementation HouseAdManager

#pragma mark -
#pragma mark Reklāmas ielāde

- (void)loadAd {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	ALDeviceInfo *deviceInfo = [[ALDeviceInfo alloc] init];
	NSString *hwModel = deviceInfo.type;
	NSString *osVersion = deviceInfo.osVersion;

	NSString *adURL = [NSString stringWithFormat:@"http:ndu/~ndudareva/ad-%@-%@.plist", hwModel, osVersion];
	[deviceInfo release];

	NSData *data = [self downloadDataFromURL:adURL];
	if (data) {
		NSPropertyListFormat format;
		NSString *error = nil;
		
		NSDictionary *dictionary = (NSDictionary *)[NSPropertyListSerialization
													propertyListFromData:data
													mutabilityOption:NSPropertyListMutableContainersAndLeaves
													format:&format errorDescription:&error];
		if (dictionary) {
			NSString *url = [dictionary objectForKey:@"bannerURL"];
			if (url) {
				[self readFile:bannerFileName URL:url];
				
				[houseAdInfo setAdIsLoaded:YES];
				[houseAdInfo setBannerShowCount:[[dictionary objectForKey:@"impressions"] integerValue]];
				[houseAdInfo setBannerEndDate:[dictionary objectForKey:@"validTill"]];
				
				if ([houseAdInfo bannerEndDate] ) {
					[houseAdInfo setNextServerCheckDate:[houseAdInfo bannerEndDate]];
				} else {
					[houseAdInfo setNextServerCheckDate:[[NSDate alloc] initWithTimeIntervalSinceNow:(24.0f * 3600.0f)]];
				}
				
				[self storeHouseAdInfo];
			}
		}
	}
	
	[pool release];
}

- (void)showAd:(UINavigationController *)navigationController {
	if ([self prepareAd]) {
		// tiek parādīts logs ar reklāmu
		HouseAdViewController *houseAdViewController = [[HouseAdViewController alloc] initWithNibName:@"HouseAdViewController" bundle:nil];
		[navigationController presentModalViewController:houseAdViewController animated:NO];
		[houseAdViewController startShowing:[UIImage imageWithData:[self readFile:bannerFileName URL:nil]]];
		[houseAdViewController release];
	} 
	
	if (![houseAdInfo nextServerCheckDate] || [[houseAdInfo nextServerCheckDate] compare:[NSDate date]] != NSOrderedDescending) {	
		[self performSelectorInBackground:@selector(loadAd) withObject:nil];
	}
}

- (BOOL)prepareAd {
	[self loadHouseAdInfo];

	// ja reklāma ir ielādēta
	// ja nākošais rādīšanas laiks jau iestājās
	// ja rādīšanu skaits nav 0 vai reklāma jārāda vienmēr
	// ja reklāma vēl ir derīga
	if ([houseAdInfo adIsLoaded] 
		&& [houseAdInfo nextShowDate] && [[houseAdInfo nextShowDate] compare:[NSDate date]] != NSOrderedDescending
		&& ([houseAdInfo bannerShowCount] > 0 || [houseAdInfo bannerShowCount] == -1)
		&& [houseAdInfo bannerEndDate] && [[houseAdInfo bannerEndDate] compare:[NSDate date]] == NSOrderedDescending) {
			return YES;
	}
	return NO;
}

- (void)dismissAd {
	[houseAdInfo setNextShowDate:[NSDate dateWithTimeIntervalSinceNow:(24.0f * 3600.0f)]];
	if ([houseAdInfo bannerShowCount] != -1) {
		[houseAdInfo setBannerShowCount:[houseAdInfo bannerShowCount] - 1];
	}
	
	[self storeHouseAdInfo];
}

- (void)loadHouseAdInfo {
	NSString *path = [dataDirPath stringByAppendingPathComponent:kHouseAdInfoFileName];
	houseAdInfo = [[NSKeyedUnarchiver unarchiveObjectWithFile:path] retain];
	
	if (!houseAdInfo) {
		houseAdInfo = [[HouseAdInfo alloc] init];
		houseAdInfo.nextShowDate = [[NSDate	alloc] initWithTimeIntervalSinceNow:(24.0f * 3600.0f)];
		[self storeHouseAdInfo];
	}
}

- (void)storeHouseAdInfo {
	NSString *path = [dataDirPath stringByAppendingPathComponent:kHouseAdInfoFileName];
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
