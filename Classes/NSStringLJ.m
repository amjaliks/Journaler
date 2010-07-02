//
//  NSStringLJ.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.01.
//  Copyright 2010 A25. All rights reserved.
//

#import "NSStringLJ.h"
#import "RegexKitLite.h"


@implementation NSString (NSStringLJ)

- (NSString *)removeTag:(NSString *)tag replacement:(NSString *)replacement format:(NSString *)format {
	NSString *string = self;
	while (true) {
		NSString *match = [string stringByMatching:tag options:RKLDotAll | RKLCaseless inRange:NSMakeRange(0, [string length]) capture:0 error:nil];
		if (!match) {
			break;
		}
		
		NSString *user = [match stringByMatching:replacement options:RKLDotAll | RKLCaseless inRange:NSMakeRange(0, [match length]) capture:1 error:nil];
		if (format) {
			user = [NSString stringWithFormat:format, user];
		}
		string = [string stringByReplacingOccurrencesOfString:match withString:user];
	}
	return string;}

@end
