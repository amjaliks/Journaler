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

@end


@implementation LJFlatRequest

- (id)initWithServer:(NSString *)server mode:(NSString *)mode; {
	if (self = [super init]) {
		_server = server;
		_mode = mode;
		
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
	
	NSLog(@"respone:\n%@", response);
		
	NSArray *lines = [response componentsSeparatedByString:@"\n"];
	NSUInteger count = [lines count] / 2;
	result = [NSMutableDictionary dictionaryWithCapacity:count];
	
	for (NSUInteger i = 0; i < count; i++) {
		[result setValue:[lines objectAtIndex:(i * 2) + 1] forKey:[lines objectAtIndex:(i * 2)]];
	}
	
	return self.success;
}

- (BOOL)success {
	if (result) {
		return [@"OK" isEqual:[result valueForKey:@"success"]];
	} else {
		return NO;
	}
}

@end


@implementation LJFlatGetChallenge

+ (LJFlatGetChallenge *)requestWithServer:(NSString *)server {
	LJFlatGetChallenge *request = [[LJFlatGetChallenge alloc] initWithServer:server mode:@"getchallenge"];
	return request;
}

- (NSString *)challenge {
	return [result valueForKey:@"challenge"];
}

@end


@implementation LJFlatLogin

+ (LJFlatLogin *)requestWithServer:(NSString *)server user:(NSString *)user password:(NSString *)password challenge:(NSString *)challenge {
	LJFlatLogin *request = [[LJFlatLogin alloc] initWithServer:server mode:@"login"];
	
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

@end
