//
//  HouseAdManager.m
//  Journaler
//
//  Created by Natālija Dudareva on 7/9/10.
//  Copyright 2010 A25. All rights reserved.
//

#import "HAManager.h"
#import "SynthesizeSingleton.h"
#import "Macros.h"
#import "NSStringMD5.h"
#import "HAViewController.h"

#import "ALDeviceInfo.h"

#define kHouseAdInfoFileName @"info.bin"
#define bannerFileName @"banner.png"
#define smallBannerFileName @"smallbanner.png"

@implementation HAManager

#pragma mark -
#pragma mark Reklāmas ielāde

- (void)loadAd {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	ALDeviceInfo *deviceInfo = [ALDeviceInfo deviceInfo];
	NSString *hwModel = deviceInfo.type;
	NSString *osVersion = deviceInfo.osVersion;
#ifndef LITEVERSION
	NSString *appUID = @"tM7hdncHys";
#else
	NSString *appUID = @"LrAKgAl3bA";
#endif
	
	NSString *adURL = [NSString stringWithFormat:@"http://a25apps.net/ads/ad-%@-%@-%@.plist", appUID, hwModel, osVersion];
	NSData *data = [self downloadDataFromURL:adURL];
	
	if (data) {
		NSPropertyListFormat format;
		NSString *error = nil;
		
		NSDictionary *dictionary = (NSDictionary *)[NSPropertyListSerialization
													propertyListFromData:data
													mutabilityOption:NSPropertyListMutableContainersAndLeaves
													format:&format errorDescription:&error];
		if (dictionary) {
			NSString *bannerURL = [dictionary objectForKey:@"bannerURL"];
			if (bannerURL) {
				[self downloadDataFromURL:bannerURL toPath:bannerPath];
				
				NSString *smallBannerURL = [dictionary objectForKey:@"smallBannerURL"];
				if (smallBannerURL) {
					[self downloadDataFromURL:smallBannerURL toPath:smallBannerPath];
					info.smallBannerLoaded = YES;
				} else {
					info.smallBannerLoaded = NO;
				}
				
				info.targetURL = [dictionary objectForKey:@"targetURL"];
				info.adIsLoaded = YES;
				info.bannerShowCount = [[dictionary objectForKey:@"impressions"] integerValue];
				info.bannerEndDate = [dictionary objectForKey:@"validTill"];
				
				if (info.bannerEndDate) {
					info.nextServerCheckDate = info.bannerEndDate;
				} else {
					info.nextServerCheckDate = [[[NSDate alloc] initWithTimeIntervalSinceNow:(24.0f * 3600.0f)] autorelease];
				}
				
				[self storeInfo];
			}
		}
	}
	
	[pool release];
}

- (void)showAd:(UINavigationController *)navigationController {
	if ([self prepareAd]) {
		// tiek parādīts logs ar reklāmu
		HAViewController *houseAdViewController = [[HAViewController alloc] initWithNibName:@"HAViewController" bundle:nil];
	
		[navigationController presentModalViewController:houseAdViewController animated:NO];
		if (image) {
			houseAdViewController.imageView.image = image;
			houseAdViewController.url = targetURL;
		}
		[houseAdViewController release];
	} 
	
	if (YES || !info.nextServerCheckDate || [info.nextServerCheckDate compare:[NSDate date]] != NSOrderedDescending) {	
		[self performSelectorInBackground:@selector(loadAd) withObject:nil];
	}
}

- (BOOL)prepareAd {
	[self loadInfo];

	// ja ir laiks rādīt reklāmu
	// ja reklāma ir ielādēta
	// ja rādīšanu skaits nav 0 vai reklāma jārāda vienmēr
	// ja reklāma vēl ir derīga

	if ([info nextShowDate] && [[info nextShowDate] compare:[NSDate date]] != NSOrderedDescending) {
		if ([info adIsLoaded] 
			&& ([info bannerShowCount] > 0 || [info bannerShowCount] == -1)
			&& [info bannerEndDate] && [[info bannerEndDate] compare:[NSDate date]] == NSOrderedDescending) {
			
			image = [UIImage imageWithContentsOfFile:bannerPath];
			targetURL = [info targetURL];
			return YES;
		} else {
#ifdef LITEVERSION
			return YES;
#endif
		}

	}
	
	return NO;
}

- (void)dismissAd {
	info.nextShowDate = [NSDate dateWithTimeIntervalSinceNow:(24.0f * 3600.0f)];
	if (info.bannerShowCount) {
		info.bannerShowCount--;
	}
	
	[self storeInfo];
}

- (void)loadInfo {
	NSString *path = [dataDirPath stringByAppendingPathComponent:kHouseAdInfoFileName];
	info = [[NSKeyedUnarchiver unarchiveObjectWithFile:path] retain];
	
	if (!info) {
		info = [[HAInfo alloc] init];
		info.nextShowDate = [NSDate dateWithTimeIntervalSinceNow:(24.0f * 3600.0f)];
		[self storeInfo];
	}
}

- (void)storeInfo {
	NSString *path = [dataDirPath stringByAppendingPathComponent:kHouseAdInfoFileName];
	[NSKeyedArchiver archiveRootObject:info toFile:path];
}

- (UIView *)bannerView {
	UIImage *bannerImage = [UIImage imageWithContentsOfFile:smallBannerPath];
	if (bannerImage) {
		UIButton *bannerView = [UIButton buttonWithType:UIButtonTypeCustom];
		[bannerView addTarget:self action:@selector(showAd:) forControlEvents:UIControlEventTouchUpInside];
		[bannerView setImage:bannerImage forState:UIControlStateNormal];
		bannerView.frame = CGRectMake(0, 0, 320.0f, 50.0f);
		return bannerView;
	} else {
		return nil;
	}
}

#pragma mark -
#pragma mark Failu lasīšana un ielāde

- (void)downloadDataFromURL:(NSString *)URL toPath:(NSString *)path {
	[[self downloadDataFromURL:URL] writeToFile:path atomically:YES];
}

- (NSData *)downloadDataFromURL:(NSString *)URL {
	NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
	
	NSURLResponse *res = nil;
	NSError *err = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
	
	if (err || [res statusCode] != 200) {
		return nil;
	} else {
		return data;
	}
}


#pragma mark -
#pragma mark Singleton metodes

SYNTHESIZE_SINGLETON_FOR_CLASS(HAManager)

- (id)init {
	if (self = [super init]) {
		dataDirPath = [[appCachesDir stringByAppendingPathComponent:@"houseAds"] retain];
		NSFileManager *mng = [NSFileManager defaultManager];
		if (![mng fileExistsAtPath:dataDirPath]) {
			[mng createDirectoryAtPath:dataDirPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
		
		bannerPath = [[dataDirPath stringByAppendingPathComponent:@"banner.png"] retain];
		smallBannerPath = [[dataDirPath stringByAppendingPathComponent:@"smallbanner.png"] retain];
	}
	return self;
}

@end
