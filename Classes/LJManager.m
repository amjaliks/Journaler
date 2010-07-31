//
//  LJManager.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.26.
//  Copyright 2010 A25. All rights reserved.
//

#import "LJManager.h"
#import "LiveJournal.h"

#import "JournalerAppDelegate.h"
#import "SynthesizeSingleton.h"
#import "Macros.h"


@implementation LJManager

#pragma mark -
#pragma mark Raksti
#pragma mark - komandas

- (void)loadPostsForAccount:(LJAccount *)account {
	@synchronized (account) {
		if (![self loadingPostsForAccount:account] && ![loadedPosts objectForKey:account]) {
			[loadingPosts addObject:account];
			[self performSelectorInBackground:@selector(backgroundLoadPostsForAccount:) withObject:account];
		} else {
			[self postNotification:LJManagerDidLoadPostsNotification account:account];
		}
	}
}

- (void)forceLoadPostsForAccount:(LJAccount *)account {
	NSMutableArray *posts = [[model findPostsByAccount:account.title] mutableCopy];
	if (!posts) {
		posts = [[NSMutableArray alloc] init];
	}
	[loadedPosts setObject:[posts autorelease] forKey:account];
}

- (void)refreshPostsForAccount:(LJAccount *)account {
	@synchronized (account) {
		if (![self loadingPostsForAccount:account]) {
			[loadingPosts addObject:account];
			[self performSelectorInBackground:@selector(backgroundRefreshPostsForAccount:) withObject:account];
		}
	}
}

- (void)removePostsForAccount:(LJAccount *)account {
	NSArray *posts = [model findPostsByAccount:account.title];
	for (Post *post in posts) {
		[model deletePost:post];
	}
	[model saveAll];
	
	[loadedPosts removeObjectForKey:account];
}

#pragma mark - dati

- (BOOL)loadingPostsForAccount:(LJAccount *)account {
	return [loadingPosts containsObject:account];
}

- (NSArray *)loadedPostsForAccount:(LJAccount *)account {
	return [loadedPosts objectForKey:account];
}


#pragma mark - fona procesi

- (void)backgroundLoadPostsForAccount:(LJAccount *)account {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// ielādējam ierakstus no keša
	NSMutableArray *posts = [[model findPostsByAccount:account.title] mutableCopy];
	if (!posts) {
		posts = [[NSMutableArray alloc] init];
	}
	[loadedPosts setObject:[posts autorelease] forKey:account];
	
	
	if (DEFAULT_BOOL(@"refresh_on_start")) {
		[self postNotification:LJManagerDidLoadPostsNotification account:account];

		NSDate *lastSync = nil;
		if ([posts count]) {
			lastSync = [[posts objectAtIndex:0] dateTime];
		}
		
		NSError *error = nil;
		NSArray *newPosts = [client friendsPageEventsForAccount:account lastSync:lastSync error:&error];
		
		if (error) {
			@synchronized (account) {
				[loadingPosts removeObject:account];
			}
			[self postFailNotificationForAccount:account error:error];
			return;
		}
		
		[self mergeCachedPosts:posts withNewPosts:newPosts forAccount:account];
	}

	@synchronized (account) {
		[loadingPosts removeObject:account];
	}
	[self postNotification:LJManagerDidLoadPostsNotification account:account];
	
	[pool release];
}

- (void)backgroundRefreshPostsForAccount:(LJAccount *)account {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSMutableArray *posts = [loadedPosts objectForKey:account];
	if (!posts) {
		posts = [[NSMutableArray alloc] init];
	}
	
	NSError *error = nil;
	NSArray *newPosts = [client friendsPageEventsForAccount:account lastSync:nil error:&error];
	
	if (error) {
		@synchronized (account) {
			[loadingPosts removeObject:account];
		}
		[self postFailNotificationForAccount:account error:error];
		return;
	}
	
	[self mergeCachedPosts:posts withNewPosts:newPosts forAccount:account];
	
	@synchronized (account) {
		[loadingPosts removeObject:account];
	}	
	[self postNotification:LJManagerDidLoadPostsNotification account:account];
	
	[pool release];
}

- (void)mergeCachedPosts:(NSMutableArray *)cachedPosts withNewPosts:(NSArray *)newPosts forAccount:(LJAccount *)account {
	for (LJEvent *event in newPosts) {
		Post *post = [model findPostByAccount:account.title journal:event.journal dItemId:event.ditemid];
		if (!post) {
			post = [model createPost];
			post.account = account.title;
			post.journal = event.journal;
			post.journalType = [NSNumber numberWithInt:event.journalType];
			post.journalTypeOld = event.journalType == LJJournalTypeJournal ? @"J" : @"C"; // savietojamība
			post.ditemid = event.ditemid;
			post.poster = event.poster;
			post.isRead = [NSNumber numberWithBool:NO];
			[cachedPosts addObject:post];
		}
		post.dateTime = event.datetime;
		post.subject = event.subject;
		post.text = event.event;
		post.replyCount = [NSNumber numberWithInt:event.replyCount];
		post.userPicURL = event.userPicUrl;
		post.security = event.security == LJEventSecurityPublic ? @"public" : @"private";
		post.updated = YES;
		post.rendered = NO;
		[post clearPreproceedStrings];
	}
	
	NSSortDescriptor *dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:NO];
	[cachedPosts sortUsingDescriptors:[NSArray arrayWithObjects:dateSortDescriptor, nil]];
	[dateSortDescriptor release];
	
	while ([cachedPosts count] > 100) {
		Post *last = [cachedPosts lastObject];
		[cachedPosts removeLastObject];
		[model deletePost:last];
	}
	
	[model saveAll];
}

#pragma mark -
#pragma mark Sesijas

- (void)createSessionForAccount:(LJAccount *)account {
	@synchronized (self) {
		if (![generatingSession containsObject:account]) {
			// ja nav netiek ģenerēta sesija, tad pārbaudam, vai ir jau pieejama derīga sesija
			LJSession *session = [sessions objectForKey:account];
			if ([session isValid]) {
				[self postNotification:LJManagerDidCreateSessionNotification account:account];
			} else {
				if (session) {
					[sessions removeObjectForKey:account];
				}
				[generatingSession addObject:account];
				[self performSelectorInBackground:@selector(backgroundCreateSessionForAccount:) withObject:account];
			}
		}
	}
}

- (void)setHTTPCookiesForAccount:(LJAccount *)account {
	LJSession *session = [sessions objectForKey:account];
	
	NSDictionary *cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"ljsession", NSHTTPCookieName, session.sessionID, NSHTTPCookieValue, [NSString stringWithFormat:@".%@", account.server], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
	NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
	[cookie release];
	
	cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"ljmastersession", NSHTTPCookieName, session.sessionID, NSHTTPCookieValue, [NSString stringWithFormat:@".%@", account.server], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
	cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
	[cookie release];
	
	NSArray *parts = [session.sessionID componentsSeparatedByString:@":"];
	cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"ljloggedin", NSHTTPCookieName, [NSString stringWithFormat:@"%@:%@", [parts objectAtIndex:1], [parts objectAtIndex:2]], NSHTTPCookieValue, [NSString stringWithFormat:@".%@", account.server], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, nil];
	cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
	[cookie release];
}

- (void)backgroundCreateSessionForAccount:(LJAccount *)account {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSError *error = nil;
	LJSession *session = [client generateSessionForAccount:account error:&error];
	
	if (error) {
		[self postFailNotificationForAccount:account error:error];
	} else {				
		@synchronized (self) {
			[sessions setObject:session forKey:account];
			[generatingSession removeObject:account];
			[self postNotification:LJManagerDidCreateSessionNotification account:account];
		}
	}
	
	[pool release];
}

#pragma mark -
#pragma mark Rutīnas metodes

- (void)postNotification:(NSString *)name account:(LJAccount *)account {
	[notificationCenter postNotificationName:name 
									  object:self 
									userInfo:[NSDictionary dictionaryWithObject:account forKey:@"account"]];
}

- (void)postFailNotificationForAccount:(LJAccount *)account error:(NSError *)error {
	[notificationCenter postNotificationName:LJManagerDidFailNotification 
									  object:self 
									userInfo:[NSDictionary dictionaryWithObjectsAndKeys:account, @"account", error, @"error", nil]];
}

- (void)didReceiveMemoryWarning {
	[loadedPosts removeAllObjects];
}

#pragma mark -
#pragma mark Singleton metodes

- (id)init {
	if (self = [super init]) {
		notificationCenter = [NSNotificationCenter defaultCenter];
		
		loadingPosts = [[NSMutableSet alloc] init];
		loadedPosts = [[NSMutableDictionary alloc] init];
		
		generatingSession = [[NSMutableSet alloc] init];
		sessions = [[NSMutableDictionary alloc] init];
	}
	return self;
}

SYNTHESIZE_SINGLETON_FOR_CLASS(LJManager)

@end
