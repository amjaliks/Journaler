//
//  LiveJournal.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.02.
//  Copyright 2009 A25. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "LiveJournal.h"


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

- (NSString *)ljsession {
	return [result valueForKey:@"ljsession"];
}

@end
