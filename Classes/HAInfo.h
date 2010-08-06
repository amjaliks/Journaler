//
//  HouseAdInfo.h
//  Journaler
//
//  Created by Natālija Dudareva on 7/13/10.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HAInfo : NSObject<NSCoding> {
	NSDate *nextShowDate;
	NSDate *nextServerCheckDate;
	NSDate *bannerEndDate;
	NSInteger bannerShowCount;
	NSString *targetURL;
	BOOL adIsLoaded;
	BOOL smallBannerLoaded;
}

@property (retain, nonatomic) NSDate *nextShowDate;
@property (retain, nonatomic) NSDate *nextServerCheckDate;
@property (retain, nonatomic) NSDate *bannerEndDate;
@property NSInteger bannerShowCount;
@property (retain, nonatomic) NSString *targetURL;
@property BOOL adIsLoaded;
@property BOOL smallBannerLoaded;

@end
