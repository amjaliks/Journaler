//
//  HouseAdInfo.h
//  Journaler
//
//  Created by Natālija Dudareva on 7/13/10.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HouseAdInfo : NSObject<NSCoding> {
	NSDate *nextShowDate;
	NSDate *nextServerCheckDate;
	NSDate *bannerEndDate;
	NSInteger bannerShowCount;
	BOOL adIsLoaded;
}

@property (retain, nonatomic) NSDate *nextShowDate;
@property (retain, nonatomic) NSDate *nextServerCheckDate;
@property (retain, nonatomic) NSDate *bannerEndDate;
@property NSInteger bannerShowCount;
@property BOOL adIsLoaded;

@end
