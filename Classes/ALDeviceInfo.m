//
//  ALDeviceInfo.m
//  Appnlytics
//
//  Created by Aleksejs Mjaliks on 09.11.02.
//  Copyright 2009 A25. All rights reserved.
//

#import <sys/sysctl.h>
#import "ALDeviceInfo.h"


@implementation ALDeviceInfo

@synthesize UDID;
@synthesize type;
@synthesize osVersion;
@synthesize uiLang;
@synthesize appVersion;
@synthesize cracked;

- (id) init {
	self = [super init];
	if (self != nil) {
		// iekārtas informācijas (UDID, OS versija)
		UIDevice *device = [UIDevice currentDevice];
		UDID = [[device uniqueIdentifier] retain];
		osVersion = [[device systemVersion] retain];
		
		// iekārtas veids
		type = [self hardwareModel];
		
		// UI valoda
		NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
		NSArray* languages = [defs objectForKey:@"AppleLanguages"];
		NSString* preferredLang = [[languages objectAtIndex:0] substringWithRange:NSMakeRange(0, 2)];
		uiLang = [preferredLang retain];
		
		// lietotnes versija
		appVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] retain];
		
		// pārbaude, vai lietotne ir lasta
		cracked = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SignerIdentity"] != nil;
	}
	return self;
}

- (void) dealloc {
	[UDID release];
	[osVersion release];
	[type release];
	[uiLang release];
	[appVersion release];
	
	[super dealloc];
}

- (NSString *)hardwareModel {
    static NSString *hardwareModel = nil;
    if (!hardwareModel) {
        char buffer[128];
        size_t length = sizeof(buffer);
        if (sysctlbyname("hw.machine", &buffer, &length, NULL, 0) == 0) {
            hardwareModel = [[NSString allocWithZone:NULL] initWithCString:buffer encoding:NSASCIIStringEncoding];
        }
        if (!hardwareModel || [hardwareModel length] == 0) {
            hardwareModel = @"unknown";
        }
    }
    return hardwareModel;    
}

@end
