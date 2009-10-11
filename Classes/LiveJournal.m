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


NSString* md5(NSString *str)
{
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
	];
} 


@implementation LJAccount

@synthesize user;
@synthesize password;
@synthesize server;

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [self init]) {
		user = [[coder decodeObjectForKey:@"user"] retain];
		password = [[coder decodeObjectForKey:@"password"] retain];
		server = [[coder decodeObjectForKey:@"server"] retain];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:1 forKey:@"version"];
	[coder encodeObject:user forKey:@"user"];
	[coder encodeObject:password forKey:@"password"];
	[coder encodeObject:server forKey:@"server"];
}

- (NSString *)title {
	return [NSString stringWithFormat:@"%@@%@", user, server];
}

@end


@implementation LJEvent

@synthesize journalName;
@synthesize journalType;
@synthesize posterName;
@synthesize posterType;
@synthesize subject;
@synthesize event;
@synthesize eventPreview;

+ (NSString *) removeTagFromString:(NSString *)string tag:(NSString *)tag replacement:(NSString *)replacement format:(NSString *)format {
	while (true) {
		NSLog(string);
		NSString *match = [string stringByMatching:tag options:RKLDotAll inRange:NSMakeRange(0, [string length]) capture:0 error:nil];
		if (!match) {
			break;
		}
		
		NSString *user = [match stringByMatching:replacement options:RKLDotAll inRange:NSMakeRange(0, [match length]) capture:1 error:nil];
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
	
	NSMutableString *meventPreview = [NSMutableString stringWithString:eventPreview];

	[meventPreview replaceOccurrencesOfRegex:@"<br\\s*/?>" withString:@"\n" options:(RKLDotAll | RKLCaseless) range:NSMakeRange(0, [meventPreview length]) error:nil];
	[meventPreview replaceOccurrencesOfRegex:@"<img\\s?.*/?>" withString:@"( img )" options:(RKLDotAll | RKLCaseless) range:NSMakeRange(0, [meventPreview length]) error:nil];

	[meventPreview replaceOccurrencesOfRegex:@"<.+?>" withString:@""  options:(RKLDotAll | RKLCaseless)range:NSMakeRange(0, [meventPreview length]) error:nil];

	eventPreview = [meventPreview stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];

	[eventPreview retain];

	//NSLog(NSStringFromRange());
//	while (true) {
//		NSRange pos = [eventPreview rangeOfString:@"<lj " options:0 range:forward];
//		if (pos.location == NSNotFound) {
//			break;
//		}
//		forward.location = pos.location + 1;
//		
//	}
}

@end


@implementation LJFlatRequest

@synthesize error;

- (id)initWithServer:(NSString *)server mode:(NSString *)mode; {
	if (self = [super init]) {
		_server = server;
		_mode = mode;
		
		error = 0;
		
		parameters = [NSMutableDictionary dictionary];
	}
	return self;
}

- (BOOL)doRequest {
	NSString *urlString = [NSString stringWithFormat:@"http://%@/interface/flat", _server];
	NSURL *url = [NSURL URLWithString:urlString];
	
	NSString *request = [NSString stringWithFormat:@"mode=%@", _mode];
	
	NSArray *keys = [parameters allKeys];
	for (NSString * key in keys) {
		NSString *value = [parameters objectForKey:key];
		request = [request stringByAppendingFormat:@"&%@=%@", key, value]; 
	}
	
	NSLog(@"request: %@", request);
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	[req setHTTPMethod:@"POST"];
	[req setHTTPBody:[request dataUsingEncoding:NSUTF8StringEncoding]];

	NSURLResponse *res;
	NSError *err;
	NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
	
	NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	if (err && [NSURLErrorDomain isEqualToString:[err domain]]) {
		NSInteger errcode = [err code];
		if (errcode == NSURLErrorCannotFindHost) {
			error = LJErrorHostNotFound;
		} else if (errcode == NSURLErrorTimedOut) {
			error = LJErrorConnectionFailed;
		} else {
			error = LJErrorUnknown;
			NSLog(@"Error: %d", errcode);
		}
		
		return NO;
	}
	
	NSLog(@"respone:\n%@", response);
		
	NSArray *lines = [response componentsSeparatedByString:@"\n"];
	NSUInteger count = [lines count] / 2;
	result = [NSMutableDictionary dictionaryWithCapacity:count];
	
	for (NSUInteger i = 0; i < count; i++) {
		[result setValue:[lines objectAtIndex:(i * 2) + 1] forKey:[lines objectAtIndex:(i * 2)]];
	}
	
	if (![@"OK" isEqualToString:[result valueForKey:@"success"]]) {
		[self proceedError];
	}
	
	return self.success;
}

- (BOOL)success {
	return !error;
}

- (void)proceedError {
	error = LJErrorUnknown;
}

@end


@implementation LJFlatGetChallenge

+ (LJFlatGetChallenge *)requestWithServer:(NSString *)server {
	LJFlatGetChallenge *request = [[[LJFlatGetChallenge alloc] initWithServer:server mode:@"getchallenge"] autorelease];
	return request;
}

- (NSString *)challenge {
	return [result valueForKey:@"challenge"];
}

@end


@implementation LJFlatLogin

+ (LJFlatLogin *)requestWithServer:(NSString *)server user:(NSString *)user password:(NSString *)password challenge:(NSString *)challenge {
	LJFlatLogin *request = [[[LJFlatLogin alloc] initWithServer:server mode:@"login"] autorelease];
	//LJFlatLogin *request = [[[LJFlatLogin alloc] initWithServer:server mode:@"getevents"] autorelease];
	
	[request->parameters setValue:user forKey:@"user"];
	[request->parameters setValue:@"challenge" forKey:@"auth_method"];
	[request->parameters setValue:challenge forKey:@"auth_challenge"];

	request->password = password;
	request->challenge = challenge;
	
	return request;
}

- (BOOL)doRequest {
	
	NSString *authResponse = md5([challenge stringByAppendingString:md5(password)]);
	[parameters setValue:authResponse forKey:@"auth_response"];
	
	return [super doRequest];
}

- (void)proceedError {
	NSString *errmsg = [result valueForKey:@"errmsg"];
	if ([@"Invalid username" isEqualToString:errmsg]) {
		error = LJErrorInvalidUsername;
	} else if ([@"Invalid password" isEqualToString:errmsg]) {
		error = LJErrorInvalidPassword;
	} else {
		error = LJErrorUnknown;
	}
}

@end


@implementation LJFlatSessionGenerate

+ (LJFlatSessionGenerate *)requestWithServer:(NSString *)server user:(NSString *)user password:(NSString *)password challenge:(NSString *)challenge {
	LJFlatSessionGenerate *request = [[[LJFlatSessionGenerate alloc] initWithServer:server mode:@"sessiongenerate"] autorelease];
	//LJFlatSessionGenerate *request = [[[LJFlatSessionGenerate alloc] initWithServer:server mode:@"getfriendspage"] autorelease];
	
	[request->parameters setValue:user forKey:@"user"];
	[request->parameters setValue:@"challenge" forKey:@"auth_method"];
	[request->parameters setValue:challenge forKey:@"auth_challenge"];

	//[request->parameters setValue:@"2009-10-01 00:00:00" forKey:@"lastsync"];
	
	request->password = password;
	request->challenge = challenge;
	
	return request;
}

- (BOOL)doRequest {
	
	NSString *authResponse = md5([challenge stringByAppendingString:md5(password)]);
	[parameters setValue:authResponse forKey:@"auth_response"];
	
	return [super doRequest];
}

- (void)proceedError {
	NSString *errmsg = [result valueForKey:@"errmsg"];
	if ([@"Invalid username" isEqualToString:errmsg]) {
		error = LJErrorInvalidUsername;
	} else if ([@"Invalid password" isEqualToString:errmsg]) {
		error = LJErrorInvalidPassword;
	} else {
		error = LJErrorUnknown;
	}
}

- (NSString *)ljsession {
	return [result valueForKey:@"ljsession"];
}

@end


@implementation LJFlatPostEvent

+ (LJFlatPostEvent *)requestWithServer:(NSString *)server user:(NSString *)user password:(NSString *)password challenge:(NSString *)challenge subject:(NSString *)subject event:(NSString *)event {
	LJFlatPostEvent *request = [[[LJFlatPostEvent alloc] initWithServer:server mode:@"postevent"] autorelease];
	//LJFlatSessionGenerate *request = [[[LJFlatSessionGenerate alloc] initWithServer:server mode:@"getfriendspage"] autorelease];
	
	[request->parameters setValue:user forKey:@"user"];
	[request->parameters setValue:@"challenge" forKey:@"auth_method"];
	[request->parameters setValue:challenge forKey:@"auth_challenge"];

	[request->parameters setValue:@"1" forKey:@"ver"];
	[request->parameters setValue:subject forKey:@"subject"];
	[request->parameters setValue:event forKey:@"event"];
	
	NSCalendar *cal = [NSCalendar currentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
	NSDate *date = [NSDate date];
	NSDateComponents *comps = [cal components:unitFlags fromDate:date];

	[request->parameters setValue:[NSString stringWithFormat:@"%d", [comps year]] forKey:@"year"];
	[request->parameters setValue:[NSString stringWithFormat:@"%d", [comps month]] forKey:@"mon"];
	[request->parameters setValue:[NSString stringWithFormat:@"%d", [comps day]] forKey:@"day"];
	[request->parameters setValue:[NSString stringWithFormat:@"%d", [comps hour]] forKey:@"hour"];
	[request->parameters setValue:[NSString stringWithFormat:@"%d", [comps minute]] forKey:@"min"];
	
	
	//[request->parameters setValue:@"2009-10-01 00:00:00" forKey:@"lastsync"];
	
	request->password = password;
	request->challenge = challenge;
	
	return request;
}

- (BOOL)doRequest {
	
	NSString *authResponse = md5([challenge stringByAppendingString:md5(password)]);
	[parameters setValue:authResponse forKey:@"auth_response"];
	
	return [super doRequest];
}

- (void)proceedError {
	NSString *errmsg = [result valueForKey:@"errmsg"];
	if ([@"Invalid username" isEqualToString:errmsg]) {
		error = LJErrorInvalidUsername;
	} else if ([@"Invalid password" isEqualToString:errmsg]) {
		error = LJErrorInvalidPassword;
	} else {
		error = LJErrorUnknown;
	}
}

@end


@implementation LJFlatGetFriendsPage

@synthesize entries;

+ (LJFlatGetFriendsPage *)requestWithServer:(NSString *)server user:(NSString *)user password:(NSString *)password challenge:(NSString *)challenge {
	LJFlatGetFriendsPage *request = [[[LJFlatGetFriendsPage alloc] initWithServer:server mode:@"getfriendspage"] autorelease];
	//LJFlatSessionGenerate *request = [[[LJFlatSessionGenerate alloc] initWithServer:server mode:@"getfriendspage"] autorelease];
	
	[request->parameters setValue:user forKey:@"user"];
	[request->parameters setValue:@"challenge" forKey:@"auth_method"];
	[request->parameters setValue:challenge forKey:@"auth_challenge"];

	[request->parameters setValue:@"1" forKey:@"ver"];
	[request->parameters setValue:@"25" forKey:@"itemshow"];
	[request->parameters setValue:@"2009-01-01 00:00:00" forKey:@"lastsync"];
	
	request->password = password;
	request->challenge = challenge;
	
	return request;
}

- (BOOL)doRequest {
	
	NSString *authResponse = md5([challenge stringByAppendingString:md5(password)]);
	[parameters setValue:authResponse forKey:@"auth_response"];

	[super doRequest];

	if (self.success) {
		NSString *entriesCountStr = [result valueForKey:@"entries_count"];
		int count = [entriesCountStr intValue];
		
		entries = [NSMutableArray arrayWithCapacity:count];
		
		for (int i = 1; i <= count; i++) {
			LJEvent *event = [[LJEvent alloc] init];
			event.subject = [[((NSString *) [result valueForKey:[NSString stringWithFormat:@"entries_%d_subject_raw", i]]) stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			event.event = [[((NSString *) [result valueForKey:[NSString stringWithFormat:@"entries_%d_event", i]]) stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			event.journalName = [result valueForKey:[NSString stringWithFormat:@"entries_%d_journalname", i]];
			event.journalType = [result valueForKey:[NSString stringWithFormat:@"entries_%d_journaltype", i]];
			event.posterName = [result valueForKey:[NSString stringWithFormat:@"entries_%d_postername", i]];
			event.posterType = [result valueForKey:[NSString stringWithFormat:@"entries_%d_postertype", i]];
			[entries addObject:event];
		}
	}
	return self.success;
}

- (void)proceedError {
	NSString *errmsg = [result valueForKey:@"errmsg"];
	if ([@"Invalid username" isEqualToString:errmsg]) {
		error = LJErrorInvalidUsername;
	} else if ([@"Invalid password" isEqualToString:errmsg]) {
		error = LJErrorInvalidPassword;
	} else {
		error = LJErrorUnknown;
	}
}

@end
