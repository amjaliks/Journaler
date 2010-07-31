//
//  LJSession.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.28.
//  Copyright 2010 A25. All rights reserved.
//

#import "LJSession.h"


@implementation LJSession

@synthesize sessionID;

- (id)initWithID:(NSString *)newSessionID {
	if (self = [self init]) {
		sessionID = [newSessionID retain];
		
		// lai gan sesija ir derīga 24 stundas, uzskatam, ka tā ir derīga nedaudz mazāk,
		// lai nerastos problēmas ar neprecīzu laika uzskaiti
		validTill = [[NSDate alloc] initWithTimeIntervalSinceNow:(23.5 * 3600.0)];
	}
	return self;
}

- (void)dealloc {
	[sessionID release];
	[validTill release];
	
	[super dealloc];
}

- (BOOL)isValid {
	return [validTill compare:[NSDate date]] != NSOrderedAscending;
}

@end
