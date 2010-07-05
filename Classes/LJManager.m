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

- (BOOL)loginForAccount:(LJAccount *)account error:(NSError **)error {
	@synchronized (account) {
		NSString *challenge = [self challengeForAccount:account error:error];
		
		if (challenge) {
			NSMutableDictionary *parameters = [self newParametersForAccount:account	challenge:challenge];
			[parameters setValue:@"1" forKey:@"getpickws"];
			
			NSInteger lastKnownMoodID = 0;
			for (LJMood *mood in account.moods) {
				if (lastKnownMoodID < mood.ID) {
					lastKnownMoodID = mood.ID;
				}
			}
			[parameters setValue:[NSNumber numberWithInteger:lastKnownMoodID] forKey:@"getmoods"];
			
			NSDictionary *result = [[self sendRequestToServer:account.server method:@"LJ.XMLRPC.login" parameters:parameters error:error] retain];
			[parameters release];
			if (result) {
				// atzīmējam, ka konta dati ar login metodi ir nosinhronizēti
				account.loginSynchronized = YES;
				
				// lietotājam pieejamās kopienas
				account.communities = [self readArrayOfStrings:[result valueForKey:@"usejournals"]];
				
				// lietotāju draugu grupas
				account.friendGroups = [self friendGroupsFromArray:[result valueForKey:@"friendgroups"]];
				
				// lietotāja bilžu atslēgas vārdi
				account.picKeywords = [self readArrayOfStrings:[result valueForKey:@"pickws"]];
				
				// lietotāja noskaņojumu saraksts
				NSMutableSet *moods = account.moods ? [account.moods mutableCopy] : [[NSMutableSet alloc] init];
				
				for (NSDictionary *moodDict in [result valueForKey:@"moods"]) {
					NSNumber *ID = [moodDict objectForKey:@"id"];
					NSString *name = [moodDict objectForKey:@"name"];
					
					LJMood *mood = [[LJMood alloc] initWithID:[ID integerValue] mood:name];
					[moods addObject:mood];
				}
				
				account.moods = moods;
				
				[result release];
				return YES;
			}
		}
	}
	return NO;
}

- (NSString *)generateSessionForAccount:(LJAccount *)account error:(NSError **)error {
	@synchronized (account) {
		NSString *challenge = [self challengeForAccount:account error:error];
		if (challenge) {
			NSMutableDictionary *parameters = [self newParametersForAccount:account	challenge:challenge];
			NSDictionary *result = [[self sendRequestToServer:account.server method:@"LJ.XMLRPC.sessiongenerate" parameters:parameters error:error] retain];
			[parameters release];
			
			if (result) {
				NSString *session = [result valueForKey:@"ljsession"];
				[result release];
				
				return session;
			}
		}
	}
	return nil;
}

- (NSArray *)friendsPageEventsForAccount:(LJAccount *)account lastSync:(NSDate *)lastSync error:(NSError **)error {
	@synchronized (account) {
		NSString *challenge = [self challengeForAccount:account error:error];
		if (challenge) {
			NSMutableDictionary *parameters = [self newParametersForAccount:account	challenge:challenge];
			
			// pēdējās sinhronizācijas datums
			if (lastSync) {
				[parameters setValue:[NSNumber numberWithInt:[lastSync timeIntervalSince1970]] forKey:@"lastsync"];
			}
			
			NSDictionary *result = [[self sendRequestToServer:account.server method:@"LJ.XMLRPC.getfriendspage" parameters:parameters error:error] retain];
			[parameters release];
			
			if (result) {
				// ja ir rezultāts, tad apstrādājam to
				NSArray *entries = [result valueForKey:@"entries"];
				NSMutableArray *events = [NSMutableArray arrayWithCapacity:[entries count]];
				
				for (NSDictionary *entry in entries) {
					LJEvent *event = [[LJEvent alloc] init];
					event.subject = [LJRequest proceedRawValue:[entry valueForKey:@"subject_raw"]];
					event.event = [LJRequest proceedRawValue:[entry valueForKey:@"event_raw"]];
					event.journal = [LJRequest proceedRawValue:[entry valueForKey:@"journalname"]];
					event.journalType = [LJEvent journalTypeForKey:[entry valueForKey:@"journaltype"]];
					event.poster = [LJRequest proceedRawValue:[entry valueForKey:@"postername"]];
					event.posterType = [LJEvent journalTypeForKey:[entry valueForKey:@"postertype"]];
					event.datetime = [NSDate dateWithTimeIntervalSince1970:[((NSNumber *) [entry valueForKey:@"logtime"]) integerValue]];
					event.replyCount = [((NSNumber *) [entry valueForKey:@"reply_count"]) integerValue];
					event.userPicUrl = [entry valueForKey:@"poster_userpic_url"];
					event.ditemid = [entry valueForKey:@"ditemid"];
					event.security = [LJEvent securityLevelForKey:[entry valueForKey:@"security"]];
					[events addObject:event];
					[event release];
				}
				return events;
			}
		}
	}
	return nil;
}

- (BOOL)friendGroupsForAccount:(LJAccount *)account error:(NSError **)error {
	@synchronized (account) {
		NSString *challenge = [self challengeForAccount:account error:error];
		if (challenge) {
			NSMutableDictionary *parameters = [self newParametersForAccount:account	challenge:challenge];
			NSDictionary *result = [[self sendRequestToServer:account.server method:@"LJ.XMLRPC.getfriendgroups" parameters:parameters error:error] retain];
			[parameters release];
			
			if (result) {
				// ja ir rezultāts, tad apstrādājam to
				account.friendGroups = [self friendGroupsFromArray:[result valueForKey:@"friendgroups"]];
				[result release];
				return YES;
			}
		}
	}
	return NO;
}

- (BOOL)userTagsForAccount:(LJAccount *)account error:(NSError **)error {
	@synchronized (account) {
		NSString *challenge = [self challengeForAccount:account error:error];
		if (challenge) {
			NSMutableDictionary *parameters = [self newParametersForAccount:account	challenge:challenge];
			NSDictionary *result = [[self sendRequestToServer:account.server method:@"LJ.XMLRPC.getusertags" parameters:parameters error:error] retain];
			[parameters release];
			
			if (result) {
				// atzīmējam, ka tagi ir sinhronizēti
				account.tagsSynchronized = YES;
				
				NSArray *tagDictionaries = [result objectForKey:@"tags"];
				NSMutableSet *tags = [[NSMutableSet alloc] initWithCapacity:[tagDictionaries count]];
				for (NSDictionary *tagDictionary in tagDictionaries) {
					LJTag *tag = [[LJTag alloc] initWithName:[self readStringValue:[tagDictionary objectForKey:@"name"]]];
					[tags addObject:tag];
					[tag release];
				}
				
				account.tags = tags;
				[tags release];
				
				[result release];
				return YES;
			}
		}
	}
	
	return NO;
}


- (BOOL)postEvent:(LJEvent *)event forAccount:(LJAccount *)account error:(NSError **)error {
	@synchronized (account) {
		NSString *challenge = [self challengeForAccount:account error:error];
		
		if (challenge) {
			NSMutableDictionary *parameters = [self newParametersForAccount:account	challenge:challenge];
			
			[parameters setValue:[event.subject dataUsingEncoding:NSUTF8StringEncoding] forKey:@"subject"];
			[parameters setValue:[event.event dataUsingEncoding:NSUTF8StringEncoding] forKey:@"event"];
			
			NSCalendar *cal = [NSCalendar currentCalendar];
			unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
			NSDate *date = [NSDate date];
			NSDateComponents *comps = [cal components:unitFlags fromDate:date];
			
			[parameters setValue:[NSString stringWithFormat:@"%d", [comps year]] forKey:@"year"];
			[parameters setValue:[NSString stringWithFormat:@"%d", [comps month]] forKey:@"mon"];
			[parameters setValue:[NSString stringWithFormat:@"%d", [comps day]] forKey:@"day"];
			[parameters setValue:[NSString stringWithFormat:@"%d", [comps hour]] forKey:@"hour"];
			[parameters setValue:[NSString stringWithFormat:@"%d", [comps minute]] forKey:@"min"];		
			
			[parameters setValue:event.journal forKey:@"usejournal"];
			
			if (event.security == LJEventSecurityPrivate) {
				[parameters setValue:@"private" forKey:@"security"];
			} else if (event.security != LJEventSecurityPublic) {
				[parameters setValue:@"usemask" forKey:@"security"];
				NSUInteger allowmask = 0;
				if (event.security == LJEventSecurityCustom) {
					for (NSNumber *groupID in event.selectedFriendGroups) {
						allowmask |= 1 << [groupID unsignedIntegerValue];
					}
					//allowmask <<= 1;
				} else {
					allowmask = 1;
				}
				NSNumber *allowmaskNumber = [[NSNumber alloc] initWithUnsignedInteger:allowmask];
				[parameters setValue:allowmaskNumber forKey:@"allowmask"];
				[allowmaskNumber release];
			}
			
			NSMutableDictionary *props = [[NSMutableDictionary alloc] init];
		
			if ([account supports:ServerFeaturePostEventUserAgent]) {
#ifndef LITEVERSION
				[props setValue:@"Journaler" forKey:@"useragent"];
#else
				[props setValue:@"Journaler Lite" forKey:@"useragent"];
#endif
			}
			
			if ([event.tags count]) {
				NSString *tags = [NSString string];
				for (LJTag *tag in event.tags) {
					if ([tags length] > 0) {
						tags = [tags stringByAppendingString:@","];
					}
					tags = [tags stringByAppendingString:tag.name];
				}
				[props setValue:tags forKey:@"taglist"];
			}
			
			if (event.picKeyword) {
				[props setValue:event.picKeyword forKey:@"picture_keyword"];
			}
			
			if (event.mood) {
				LJMood *mood = [account.moods member:[[[LJMood alloc] initWithMood:event.mood] autorelease]];
				if (mood) {
					[props setValue:mood.mood forKey:@"current_mood"];
					[props setValue:[NSNumber numberWithInteger:mood.ID] forKey:@"current_moodid"];
				} else {
					[props setValue:event.mood forKey:@"current_mood"];
				}
			}
			
			if (event.music) {
				[props setValue:event.music forKey:@"current_music"];
			}
			
			if (event.location) {
				[props setValue:event.location forKey:@"current_location"];
			}
		
			[parameters setValue:props forKey:@"props"];
			[props release];
			
			NSDictionary *result = [[self sendRequestToServer:account.server method:@"LJ.XMLRPC.postevent" parameters:parameters error:error] retain];
			[parameters release];
			if (result) {
				[result release];
				return YES;
			}
		}
	}
	
	return NO;
}

#pragma mark -
#pragma mark Tehniskās metodes

- (NSDictionary *)sendRequestToServer:(NSString *)server method:(NSString *)method parameters:(NSDictionary *)parameters error:(NSError **)error {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/interface/xmlrpc", server]];
	
	XMLRPCRequest *xmlreq = [[XMLRPCRequest alloc] initWithURL:url];
	[xmlreq setMethod:method withParameter:parameters];
//#ifdef DEBUG
//	NSLog(@"request:\n%@", [xmlreq body]);
//#endif
	NSURLRequest *req = [xmlreq request];
	
	[[NetworkActivityIndicator sharedInstance] show];
	
	NSURLResponse *res;
	NSError *err = nil;
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
//#ifdef DEBUG
//	NSLog(@"respone:\n%@", [xmlres body]);
//#endif
	
	if ([xmlres isFault]) {
		//code = LJErrorUnknown;
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
		if (error) {
			*error = [NSError errorWithDomain:kLJErrorDomain code:code userInfo:nil];
		}
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
	[parameters setValue:@"1" forKey:@"ver"];
	
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


- (NSArray *)friendGroupsFromArray:(NSArray *)array {
	NSMutableArray *friendGroups = [[NSMutableArray alloc] initWithCapacity:[array count]];

	for (NSDictionary *dictionary in array) {
		NSNumber *groupID = [dictionary valueForKey:@"id"];
		NSString *name = [self readStringValue:[dictionary valueForKey:@"name"]];
		NSNumber *sortOrder = [dictionary valueForKey:@"sortorder"];
		NSNumber *publicGroup = [dictionary valueForKey:@"public"];

		LJFriendGroup *friendGroup = [[LJFriendGroup alloc] initWithID:[groupID unsignedIntegerValue] name:name sortOrder:[sortOrder unsignedIntegerValue] publicGroup:[publicGroup boolValue]];
		
		[friendGroups addObject:friendGroup];
		[friendGroup release];
	}
	
	return [friendGroups autorelease];
}

- (NSArray *)readArrayOfStrings:(NSArray *)array {
	NSMutableArray *arrayOfStrings = [[NSMutableArray alloc] initWithCapacity:[array count]];
	
	for (id value in array) {
		[arrayOfStrings addObject:[self readStringValue:value]];
	}
	
	return [arrayOfStrings autorelease];
}

#pragma mark -
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
