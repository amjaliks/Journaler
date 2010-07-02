//
//  LiveJournal.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.02.
//  Copyright 2009 A25. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "LiveJournal.h"
#import "RegexKitLite.h"
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"

#import "NetworkActivityIndicator.h"

@implementation LJEvent2

@synthesize journalName;
@synthesize journalType;
@synthesize posterName;
@synthesize posterType;
@synthesize subject;
@synthesize event;
@synthesize datetime;
@synthesize replyCount;
@synthesize eventPreview;
@synthesize userPicUrl;
@synthesize ditemid;
@synthesize security;

+ (NSString *) removeTagFromString:(NSString *)string tag:(NSString *)tag replacement:(NSString *)replacement format:(NSString *)format {
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
	return string;
}

- (void) setEvent:(NSString *)_event {
	event = [_event retain];
	eventPreview = [_event retain];
	
	NSRange notFoundRange;
	notFoundRange.location = NSNotFound;
	notFoundRange.length = 0;
	
	NSRange forward;
	forward.location = 0;
	forward.length = [eventPreview length];
	
	eventPreview = [LJEvent removeTagFromString:eventPreview tag:@"<lj user=\".+?\">" replacement:@"\"(.+?)\"" format:nil];
	eventPreview = [LJEvent removeTagFromString:eventPreview tag:@"<lj-cut text=\".+?\">.*?</lj-cut>" replacement:@"text=\"(.+?)\"" format:@"( %@ )"];
	eventPreview = [eventPreview stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	eventPreview = [eventPreview stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
	eventPreview = [eventPreview stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
	
	NSMutableString *meventPreview = [NSMutableString stringWithString:eventPreview];

	[meventPreview replaceOccurrencesOfRegex:@"<br\\s*/?>" withString:@" " options:(RKLDotAll | RKLCaseless) range:NSMakeRange(0, [meventPreview length]) error:nil];
	[meventPreview replaceOccurrencesOfRegex:@"<img\\s?.*?/?>" withString:@"( img )" options:(RKLDotAll | RKLCaseless) range:NSMakeRange(0, [meventPreview length]) error:nil];
	[meventPreview replaceOccurrencesOfRegex:@"<.+?>" withString:@""  options:(RKLDotAll | RKLCaseless)range:NSMakeRange(0, [meventPreview length]) error:nil];
	[meventPreview replaceOccurrencesOfRegex:@"&.+?;" withString:@""  options:(RKLDotAll | RKLCaseless)range:NSMakeRange(0, [meventPreview length]) error:nil];

	eventPreview = [meventPreview retain];
}

- (NSString *) eventView {
	if (!eventView) {
		eventView = [event retain];
		
		NSRange notFoundRange;
		notFoundRange.location = NSNotFound;
		notFoundRange.length = 0;
		
		NSRange forward;
		forward.location = 0;
		forward.length = [eventPreview length];
		
		eventView = [LJEvent removeTagFromString:eventView tag:@"<lj user=\".+?\">" replacement:@"\"(.+?)\"" format:nil];
		eventView = [LJEvent removeTagFromString:eventView tag:@"<img\\s?.*?/?>" replacement:@"src=\"(.+?)\"" format:@"( <a href=\"%@\">img</a> )"];
		
		eventView = [eventView stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
		
		[eventView retain];
	}
	
	return eventView;
}

@end


@implementation LJRequest

@synthesize error;

+ (id)proceedRawValue:(id) value {
	if ([value isKindOfClass:[NSData class]]) {
		return [[[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding] autorelease];
	} else if ([value isKindOfClass:[NSNumber class]]) {
		return [((NSNumber *) value) stringValue];
	} else {
		return value;
	}
}

- (id)initWithServer:(NSString *)server method:(NSString *)method; {
	return self;
}

- (BOOL)doRequest {
	return YES;
}

- (BOOL)success {
	return YES;
}

@end
