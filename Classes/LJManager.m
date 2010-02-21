//
//  LJManager.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.21.
//  Copyright 2010 A25. All rights reserved.
//

#import "LJManager.h"
#import "LJFriendGroup.h"
#import "LiveJournal.h"

#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"

#import "NetworkActivityIndicator.h"
#import "NSStringMD5.h"


LJManager *defaultManager;


@implementation LJManager

#pragma mark LJ metodes

- (NSString *)challengeForAccount:(LJAccount *)account error:(NSError **)error {
	NSDictionary *result = [[self sendRequestToServer:account.server method:@"LJ.XMLRPC.getchallenge" parameters:nil error:error] retain];
	
	if (result) {
		NSString *challenge = [result valueForKey:@"challenge"];
		[result release];
		return challenge;
	} else {
		return nil;
	}
}

- (NSArray *)friendGroupsForAccount:(LJAccount *)account error:(NSError **)error {
	NSString *challenge = [self challengeForAccount:account error:error];
	if (challenge) {
		NSMutableDictionary *parameters = [self newParametersForAccount:account	challenge:challenge];
		NSDictionary *result = [[self sendRequestToServer:account.server method:@"LJ.XMLRPC.getfriendgroups" parameters:parameters error:error] retain];
		[parameters release];
		
		if (result) {
			// ja ir rezultāts, tad apstrādājam to
			
			// rezultātā jābūt masīvam ar grupu datiem
			NSArray *friendGroupArrayRaw = [result valueForKey:@"friendgroups"];
			
			// šajā masīvā glabāsim ielasītās grupas
			NSMutableArray *friendGroups = [[NSMutableArray alloc] initWithCapacity:[friendGroupArrayRaw count]];
			
			for (NSDictionary *friendGroupRaw in friendGroupArrayRaw) {
				LJFriendGroup *friendGroup = [self newFriendGroupFromDictionary:friendGroupRaw];
				[friendGroups addObject:friendGroup];
				[friendGroup release];
			}
			
			[result release];
			return [friendGroups autorelease];
		}
	}

	return nil;
}


#pragma mark Tehniskās metodes

- (NSDictionary *)sendRequestToServer:(NSString *)server method:(NSString *)method parameters:(NSDictionary *)parameters error:(NSError **)error {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/interface/xmlrpc", server]];
	
	XMLRPCRequest *xmlreq = [[XMLRPCRequest alloc] initWithURL:url];
	[xmlreq setMethod:method withParameter:parameters];
#ifdef DEBUG
	NSLog(@"request:\n%@", [xmlreq body]);
#endif
	NSURLRequest *req = [xmlreq request];
	
	[[NetworkActivityIndicator sharedInstance] show];
	
	NSURLResponse *res;
	NSError *err;
	NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
	
	[[NetworkActivityIndicator sharedInstance] hide];
	
	[xmlreq release];
	
	NSInteger code = 0;

	if (err && [NSURLErrorDomain isEqualToString:[err domain]]) {
		NSInteger errcode = [err code];
		if (errcode == NSURLErrorCannotFindHost) {
			code = LJErrorHostNotFound;
		} else if (errcode == NSURLErrorTimedOut || errcode == NSURLErrorCannotConnectToHost) {
			code = LJErrorConnectionFailed;
		} else if (errcode == NSURLErrorNotConnectedToInternet) {
			code = LJErrorNotConnectedToInternet;
		} else {
#ifdef DEBUG
			NSLog(@"Error: %d", errcode);
#endif
			code = LJErrorUnknown;
		}
		
		*error = [NSError errorWithDomain:kLJErrorDomain code:code userInfo:nil];
		return nil;
	}
	
	XMLRPCResponse *xmlres = [[XMLRPCResponse alloc] initWithData:data];
	NSDictionary *result = [[xmlres object] retain];
#ifdef DEBUG
	NSLog(@"respone:\n%@", [xmlres body]);
#endif
	
	if ([xmlres isFault]) {
		code = LJErrorUnknown;
		id faultCode = [xmlres faultCode];
		if ([faultCode isKindOfClass:[NSString class]]) {
			code = [faultCode isEqualToString:@"Server"] ? LJErrorServerSide : LJErrorClientSide;
		} else {
			code = [((NSNumber *) faultCode) integerValue];
		}
	} else if (result == nil) {
		code = LJErrorMalformedRespone;
	}
	
	[xmlres autorelease];
	
	if (code) {
		*error = [NSError errorWithDomain:kLJErrorDomain code:code userInfo:nil];
		return nil;
	} else {
		return [result autorelease];
	}
}


- (NSMutableDictionary *)newParametersForAccount:(LJAccount *)account challenge:(NSString *)challenge {
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	
	[parameters setValue:account.user forKey:@"username"];
	[parameters setValue:@"challenge" forKey:@"auth_method"];
	[parameters setValue:challenge forKey:@"auth_challenge"];
	[parameters setValue:[[challenge stringByAppendingString:[account.password MD5Hash]] MD5Hash] forKey:@"auth_response"];
	
	return parameters;
}


- (NSString *)readStringValue:(id)value {
	if ([value isKindOfClass:[NSData class]]) {
		return [[[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding] autorelease];
	} else if ([value isKindOfClass:[NSNumber class]]) {
		return [((NSNumber *) value) stringValue];
	} else {
		return value;
	}
}


- (LJFriendGroup *)newFriendGroupFromDictionary:(NSDictionary *)dictionary {
	NSNumber *groupID = [dictionary valueForKey:@"id"];
	NSString *name = [self readStringValue:[dictionary valueForKey:@"name"]];
	NSNumber *sortOrder = [dictionary valueForKey:@"sortorder"];
	NSNumber *publicGroup = [dictionary valueForKey:@"public"];
	
	return [[LJFriendGroup alloc] initWithID:[groupID unsignedIntegerValue] name:name sortOrder:[sortOrder unsignedIntegerValue] publicGroup:[publicGroup boolValue]];
}


#pragma mark Singleton metodes

+ (LJManager *)defaultManager {
	@synchronized (self) {
		if (defaultManager == nil) {
			defaultManager = [[super allocWithZone:nil] init];
		}
	}
	return defaultManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self defaultManager] retain];
}

- (id)init {
	self = [super init];
	if (self != nil) {}
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
@end
