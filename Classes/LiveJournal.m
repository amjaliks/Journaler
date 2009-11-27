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

@synthesize synchronized;

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

- (BOOL) isEqual:(id)anObject {
	if (self == anObject) {
		return YES;
	}
	if (!anObject) {
		return NO;
	}
	if ([anObject isKindOfClass:[LJAccount class]]) {
		return [self.title isEqualToString:((LJAccount *) anObject).title];
	} else {
		return NO;
	}
}

@end


@implementation LJEvent

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
//#ifdef DEBUG
//		NSLog(string);
//#endif
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
		
		//NSMutableString *meventPreview = [NSMutableString stringWithString:eventPreview];
		
		//[meventPreview replaceOccurrencesOfRegex:@"<br\\s*/?>" withString:@"\n" options:(RKLDotAll | RKLCaseless) range:NSMakeRange(0, [meventPreview length]) error:nil];
		//[meventPreview replaceOccurrencesOfRegex:@"<img\\s?.*?/?>" withString:@"( img )" options:(RKLDotAll | RKLCaseless) range:NSMakeRange(0, [meventPreview length]) error:nil];
		
		//[meventPreview replaceOccurrencesOfRegex:@"<.+?>" withString:@""  options:(RKLDotAll | RKLCaseless)range:NSMakeRange(0, [meventPreview length]) error:nil];
		
		eventView = [eventView stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
		
		[eventView retain];
	}
	
	return eventView;
}

@end


//@implementation LJFlatRequest
//
//@synthesize error;
//
//- (id)initWithServer:(NSString *)server mode:(NSString *)mode; {
//	if (self = [super init]) {
//		_server = server;
//		_mode = mode;
//		
//		error = 0;
//		
//		parameters = [NSMutableDictionary dictionary];
//	}
//	return self;
//}
//
//- (BOOL)doRequest {
//	NSString *urlString = [NSString stringWithFormat:@"http://%@/interface/flat", _server];
//	NSURL *url = [NSURL URLWithString:urlString];
//	
//	NSString *request = [NSString stringWithFormat:@"mode=%@", _mode];
//	
//	NSArray *keys = [parameters allKeys];
//	for (NSString * key in keys) {
//		NSString *value = [parameters objectForKey:key];
//		request = [request stringByAppendingFormat:@"&%@=%@", key, value]; 
//	}
//	
//#ifdef DEBUG
//	NSLog(@"request: %@", request);
//#endif
//	
//	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
//	[req setHTTPMethod:@"POST"];
//	[req setHTTPBody:[request dataUsingEncoding:NSUTF8StringEncoding]];
//
//	NSURLResponse *res;
//	NSError *err;
//	NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
//	
//	NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//	
//	if (err && [NSURLErrorDomain isEqualToString:[err domain]]) {
//		NSInteger errcode = [err code];
//		if (errcode == NSURLErrorCannotFindHost) {
//			error = LJErrorHostNotFound;
//		} else if (errcode == NSURLErrorTimedOut) {
//			error = LJErrorConnectionFailed;
//		} else if (errcode == NSURLErrorNotConnectedToInternet) {
//			error = LJErrorNotConnectedToInternet;
//		} else {
//			error = LJErrorUnknown;
//#ifdef DEBUG
//			NSLog(@"Error: %d", errcode);
//#endif
//		}
//		
//		return NO;
//	}
//	
//#ifdef DEBUG
//	NSLog(@"respone:\n%@", response);
//#endif
//		
//	NSArray *lines = [response componentsSeparatedByString:@"\n"];
//	NSUInteger count = [lines count] / 2;
//	result = [NSMutableDictionary dictionaryWithCapacity:count];
//	
//	for (NSUInteger i = 0; i < count; i++) {
//		[result setValue:[lines objectAtIndex:(i * 2) + 1] forKey:[lines objectAtIndex:(i * 2)]];
//	}
//	
//	if (![@"OK" isEqualToString:[result valueForKey:@"success"]]) {
//		[self proceedError];
//	}
//	
//	return self.success;
//}
//
//- (BOOL)success {
//	return !error;
//}
//
//- (void)proceedError {
//	error = LJErrorUnknown;
//}
//
//@end


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
	if (self = [super init]) {
		_server = server;
		_method = method;
		
		error = 0;
		
		parameters = [NSMutableDictionary dictionary];
	}
	return self;
}

- (BOOL)doRequest {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/interface/xmlrpc", _server]];
	XMLRPCRequest *xmlreq = [[XMLRPCRequest alloc] initWithURL:url];
	//[[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/interface/xmlrpc", _server]]];
	//[xmlreq setMethod:_method withObject:parameters];
	[xmlreq setMethod:_method withParameter:parameters];
#ifdef DEBUG
	NSLog(@"request:\n%@", [xmlreq body]);
#endif
	NSURLRequest *req = [xmlreq request];
	
	NSURLResponse *res;
	NSError *err;
	NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
	
	if (err && [NSURLErrorDomain isEqualToString:[err domain]]) {
		NSInteger errcode = [err code];
		if (errcode == NSURLErrorCannotFindHost) {
			error = LJErrorHostNotFound;
		} else if (errcode == NSURLErrorTimedOut || errcode == NSURLErrorCannotConnectToHost) {
			error = LJErrorConnectionFailed;
		} else if (errcode == NSURLErrorNotConnectedToInternet) {
			error = LJErrorNotConnectedToInternet;
		} else {
			error = LJErrorUnknown;
#ifdef DEBUG
			NSLog(@"Error: %d", errcode);
#endif
		}
		
		[xmlreq release];
		return NO;
	}

	[xmlreq release];
	
	XMLRPCResponse *xmlres = [[XMLRPCResponse alloc] initWithData:data];
	result = [[xmlres object] retain];
#ifdef DEBUG
	NSLog(@"respone:\n%@", [xmlres body]);
#endif
	
	if ([xmlres isFault]) {
		error = LJErrorUnknown;
		id faultCode = [xmlres faultCode];
		if ([faultCode isKindOfClass:[NSString class]]) {
			error = [faultCode isEqualToString:@"Server"] ? LJErrorServerSide : LJErrorClientSide;
		} else {
			error = [((NSNumber *) faultCode) integerValue];
		}
	}
	
	[xmlres release];
	
	return self.success;
}

- (BOOL)success {
	return !error;
}

@end


//@implementation LJFlatGetChallenge
//
//+ (LJFlatGetChallenge *)requestWithServer:(NSString *)server {
//	LJFlatGetChallenge *request = [[[LJFlatGetChallenge alloc] initWithServer:server mode:@"getchallenge"] autorelease];
//	return request;
//}
//
//- (NSString *)challenge {
//	return [result valueForKey:@"challenge"];
//}
//
//@end


@implementation LJGetChallenge

+ (LJGetChallenge *)requestWithServer:(NSString *)server {
	LJGetChallenge *request = [[[LJGetChallenge alloc] initWithServer:server method:@"LJ.XMLRPC.getchallenge"] autorelease];
	return request;
}

- (NSString *)challenge {
	return [result valueForKey:@"challenge"];
}

@end


@implementation LJLogin

+ (LJLogin *)requestWithServer:(NSString *)server user:(NSString *)user password:(NSString *)password challenge:(NSString *)challenge {
	LJLogin *request = [[[LJLogin alloc] initWithServer:server method:@"LJ.XMLRPC.login"] autorelease];
	
	[request->parameters setValue:user forKey:@"username"];
	[request->parameters setValue:@"challenge" forKey:@"auth_method"];
	[request->parameters setValue:challenge forKey:@"auth_challenge"];

	request->password = password;
	request->challenge = challenge;
	
	return request;
}

- (BOOL)doRequest {
	
	
	NSString *authResponse = md5(password);
	authResponse = [challenge stringByAppendingString:authResponse];
	authResponse = md5(authResponse);
	[parameters setValue:authResponse forKey:@"auth_response"];
	
	return [super doRequest];
}

@end


@implementation LJSessionGenerate

+ (LJSessionGenerate *)requestWithServer:(NSString *)server user:(NSString *)user password:(NSString *)password challenge:(NSString *)challenge {
	LJSessionGenerate *request = [[[LJSessionGenerate alloc] initWithServer:server method:@"LJ.XMLRPC.sessiongenerate"] autorelease];
	
	[request->parameters setValue:user forKey:@"username"];
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

- (NSString *)ljsession {
	return [result valueForKey:@"ljsession"];
}

@end


@implementation LJPostEvent

+ (LJPostEvent *)requestWithServer:(NSString *)server user:(NSString *)user password:(NSString *)password challenge:(NSString *)challenge subject:(NSString *)subject event:(NSString *)event {
	LJPostEvent *request = [[[LJPostEvent alloc] initWithServer:server method:@"LJ.XMLRPC.postevent"] autorelease];
	//LJFlatSessionGenerate *request = [[[LJFlatSessionGenerate alloc] initWithServer:server mode:@"getfriendspage"] autorelease];
	
	[request->parameters setValue:user forKey:@"username"];
	[request->parameters setValue:@"challenge" forKey:@"auth_method"];
	[request->parameters setValue:challenge forKey:@"auth_challenge"];

	[request->parameters setValue:@"1" forKey:@"ver"];
	[request->parameters setValue:subject forKey:@"subject"];
	[request->parameters setValue:[event dataUsingEncoding:NSUTF8StringEncoding] forKey:@"event"];
	//[request->parameters setValue:user forKey:@"usejournal"];
	
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


@implementation LJGetFriendsPage

@synthesize entries;
@synthesize lastSync;
@synthesize itemShow;
@synthesize skip;

+ (LJGetFriendsPage *)requestWithServer:(NSString *)server user:(NSString *)user password:(NSString *)password challenge:(NSString *)challenge {
	LJGetFriendsPage *request = [[[LJGetFriendsPage alloc] initWithServer:server method:@"LJ.XMLRPC.getfriendspage"] autorelease];
	//LJFlatSessionGenerate *request = [[[LJFlatSessionGenerate alloc] initWithServer:server mode:@"getfriendspage"] autorelease];
	
	[request->parameters setValue:user forKey:@"username"];
	[request->parameters setValue:@"challenge" forKey:@"auth_method"];
	[request->parameters setValue:challenge forKey:@"auth_challenge"];

	[request->parameters setValue:@"1" forKey:@"ver"];
	//[request->parameters setValue:@"10" forKey:@"itemshow"];
	//[request->parameters setValue:@"2009-01-01 00:00:00" forKey:@"lastsync"];
	//[request->parameters setValue:@"1" forKey:@"parseljtags"];
	
	request->password = password;
	request->challenge = challenge;
	
	request->itemShow = [[NSNumber numberWithInt:10] retain];
	request->skip = [[NSNumber numberWithInt:0] retain];
	
	return request;
}

- (BOOL)doRequest {
	
	NSString *authResponse = md5([challenge stringByAppendingString:md5(password)]);
	[parameters setValue:authResponse forKey:@"auth_response"];
	
	[parameters setValue:itemShow forKey:@"itemshow"];
	[parameters setValue:skip forKey:@"skip"];
	if (lastSync) {
		[parameters setValue:[NSNumber numberWithInt:[lastSync timeIntervalSince1970]] forKey:@"lastsync"];
	}

	[super doRequest];

	if (self.success) {
		NSArray *xmlEntries = [result valueForKey:@"entries"];
		entries = [NSMutableArray arrayWithCapacity:[xmlEntries count]];
		
		for (NSDictionary *entry in xmlEntries) {
			LJEvent *event = [[LJEvent alloc] init];
			//id subjectRaw = [entry valueForKey:@"subject_raw"];
			event.subject = [LJRequest proceedRawValue:[entry valueForKey:@"subject_raw"]]; //[subjectRaw isKindOfClass:[NSString class]] ? subjectRaw : [[NSString alloc] initWithData:subjectRaw encoding:NSUTF8StringEncoding];;
			//id eventRaw = [entry valueForKey:@"event_raw"];
			event.event = [LJRequest proceedRawValue:[entry valueForKey:@"event_raw"]]; //[eventRaw isKindOfClass:[NSString class]] ? eventRaw : [[NSString alloc] initWithData:eventRaw encoding:NSUTF8StringEncoding];
			event.journalName = [entry valueForKey:@"journalname"];
			event.journalType = [entry valueForKey:@"journaltype"];
			event.posterName = [entry valueForKey:@"postername"];
			event.posterType = [entry valueForKey:@"postertype"];
			event.datetime = [NSDate dateWithTimeIntervalSince1970:[((NSNumber *) [entry valueForKey:@"logtime"]) integerValue]];
			event.replyCount = [((NSNumber *) [entry valueForKey:@"reply_count"]) integerValue];
			event.userPicUrl = [entry valueForKey:@"poster_userpic_url"];
			event.ditemid = [entry valueForKey:@"ditemid"];
			event.security = [entry valueForKey:@"security"];
			[entries addObject:event];
		}
		
//		NSString *entriesCountStr = [result valueForKey:@"entries_count"];
//		int count = [entriesCountStr intValue];
//		
//		entries = [NSMutableArray arrayWithCapacity:count];
//		
//		for (int i = 1; i <= count; i++) {
//			LJEvent *event = [[LJEvent alloc] init];
//			event.subject = [[((NSString *) [result valueForKey:[NSString stringWithFormat:@"entries_%d_subject_raw", i]]) stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//			event.event = [[((NSString *) [result valueForKey:[NSString stringWithFormat:@"entries_%d_event", i]]) stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//			event.journalName = [result valueForKey:[NSString stringWithFormat:@"entries_%d_journalname", i]];
//			event.journalType = [result valueForKey:[NSString stringWithFormat:@"entries_%d_journaltype", i]];
//			event.posterName = [result valueForKey:[NSString stringWithFormat:@"entries_%d_postername", i]];
//			event.posterType = [result valueForKey:[NSString stringWithFormat:@"entries_%d_postertype", i]];
//			[entries addObject:event];
//		}
	}
	return self.success;
}

- (void) dealloc {
	[skip release];
	[itemShow release];
	[super dealloc];
}


@end


//@implementation LJFlatGetEvents
//
//@synthesize entries;
//
//+ (LJFlatGetEvents *)requestWithServer:(NSString *)server user:(NSString *)user password:(NSString *)password challenge:(NSString *)challenge {
//	LJFlatGetEvents *request = [[[LJFlatGetEvents alloc] initWithServer:server mode:@"getevents"] autorelease];
//	//LJFlatSessionGenerate *request = [[[LJFlatSessionGenerate alloc] initWithServer:server mode:@"getfriendspage"] autorelease];
//	
//	[request->parameters setValue:user forKey:@"user"];
//	[request->parameters setValue:@"challenge" forKey:@"auth_method"];
//	[request->parameters setValue:challenge forKey:@"auth_challenge"];
//	
//	[request->parameters setValue:@"1" forKey:@"ver"];
//	[request->parameters setValue:@"lastn" forKey:@"selecttype"];
//	[request->parameters setValue:@"1" forKey:@"howmany"];
//	[request->parameters setValue:@"2009-01-01 00:00:00" forKey:@"lastsync"];
//	
//	request->password = password;
//	request->challenge = challenge;
//	
//	return request;
//}
//
//- (BOOL)doRequest {
//	
//	NSString *authResponse = md5([challenge stringByAppendingString:md5(password)]);
//	[parameters setValue:authResponse forKey:@"auth_response"];
//	
//	[super doRequest];
//	
//	if (self.success) {
////		NSString *entriesCountStr = [result valueForKey:@"entries_count"];
////		int count = [entriesCountStr intValue];
////		
////		entries = [NSMutableArray arrayWithCapacity:count];
////		
////		for (int i = 1; i <= count; i++) {
////			LJEvent *event = [[LJEvent alloc] init];
////			event.subject = [[((NSString *) [result valueForKey:[NSString stringWithFormat:@"entries_%d_subject_raw", i]]) stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
////			event.event = [[((NSString *) [result valueForKey:[NSString stringWithFormat:@"entries_%d_event", i]]) stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
////			event.journalName = [result valueForKey:[NSString stringWithFormat:@"entries_%d_journalname", i]];
////			event.journalType = [result valueForKey:[NSString stringWithFormat:@"entries_%d_journaltype", i]];
////			event.posterName = [result valueForKey:[NSString stringWithFormat:@"entries_%d_postername", i]];
////			event.posterType = [result valueForKey:[NSString stringWithFormat:@"entries_%d_postertype", i]];
////			[entries addObject:event];
////		}
//	}
//	return self.success;
//}
//
//- (void)proceedError {
//	NSString *errmsg = [result valueForKey:@"errmsg"];
//	if ([@"Invalid username" isEqualToString:errmsg]) {
//		error = LJErrorInvalidUsername;
//	} else if ([@"Invalid password" isEqualToString:errmsg]) {
//		error = LJErrorInvalidPassword;
//	} else {
//		error = LJErrorUnknown;
//	}
//}
//
//@end
