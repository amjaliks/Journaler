//
//  ALReporter.m
//  Appnlytics
//
//  Created by Aleksejs Mjaliks on 09.11.01.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALReporter.h"
#import "ALDeviceInfo.h"
#import "ALAppUse.h"
#import "ALProperty.h"


@interface ALReporter () 

- (void)performStartupTasks;

- (void)loadSavedInfo;
- (void)sendReport;

- (void)setProperty:(ALProperty *)setProperty;

@end


@implementation ALReporter

- (id)initWithAppUID:(NSString *)_appUID reportURL:(NSURL *)_reportURL {
	self = [super init];
	if (self != nil) {
		appUID = [_appUID retain];
		reportURL = [_reportURL retain];
		[self performSelectorInBackground:@selector(performStartupTasks) withObject:nil];
	}
	return self;
}

- (void)loadSavedInfo {
	// ielādējam sarakatu ar iepriekšējām lietošanas reizēm
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];
	
	// nenosūtītie ziņojumi
	unsentMessagesPath = [[path stringByAppendingPathComponent:@"messages.anl"] copy];
	unsentMessages = [[NSKeyedUnarchiver unarchiveObjectWithFile:unsentMessagesPath] mutableCopy];
	
	newMessagesAdded = NO;
	
	// šībrīža informācija par iekārtu
	currentDeviceInfo = [[ALDeviceInfo alloc] init];

	// īpašības
	sentPropertiesPath = [[path stringByAppendingPathComponent:@"properties.anl"] copy];
	sentProperties = [[NSKeyedUnarchiver unarchiveObjectWithFile:sentPropertiesPath] mutableCopy];
	
	unsentPropertiesPath = [[path stringByAppendingPathComponent:@"unsentProperties.anl"] copy];
	unsentProperties = [[NSKeyedUnarchiver unarchiveObjectWithFile:unsentPropertiesPath] mutableCopy];
	newUnsentProperties = YES;
}

- (void)sendReport {
	// pieprasījuma pamatinformācija
	NSString *post = [NSString stringWithFormat:@"apiver=1&appuid=%@&udid=%@&devType=%@&osVer=%@&uiLang=%@&appVer=%@",
					  appUID, currentDeviceInfo.UDID, currentDeviceInfo.type, currentDeviceInfo.osVersion, currentDeviceInfo.uiLang, currentDeviceInfo.appVersion];
	
	if (currentDeviceInfo.cracked) {
		post = [post stringByAppendingString:@"&cracked=true"];
	}
	
	// ja mums izdevās atrasta arī iepriekš atzīmētas lietošanas reizes, tad arī to datus iekļaujam pieprasījumā
	if (unsentMessages) {
		post = [post stringByAppendingFormat:@"&count=%d", [unsentMessages count]];
		NSUInteger i = 1;
		for (ALAppUse *oldUse in unsentMessages) {
			post = [post stringByAppendingFormat:@"&m%dname=session&m%dstart=%.0f", i, i, [oldUse.date timeIntervalSince1970] * 1000];
			i++;
		}
	}
	
	if (unsentProperties && [unsentProperties count]) {
		NSString *propertyNameList = nil;
		for (ALProperty *property in [unsentProperties allValues]) {
			if (propertyNameList) {
				propertyNameList = [propertyNameList stringByAppendingFormat:@",%@", property.name];
			} else {
				propertyNameList = property.name;
			}

			if (property.isSet) {
				NSUInteger idx = 1;
				for (NSString *value in property.stringSet) {
					post = [post stringByAppendingFormat:@"&p%@[%d]=%@", property.name, idx, value];
					idx++;					
				}
				propertyNameList = [propertyNameList stringByAppendingFormat:@"[%d]", [property.stringSet count]];
			} else {
				post = [post stringByAppendingFormat:@"&p%@=%@", property.name, property.stringValue];
			}
			
		}
		post = [post stringByAppendingFormat:@"&properties=%@", propertyNameList];
	}
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:reportURL];
	[req setHTTPMethod:@"POST"];
	[req setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSURLResponse *res;
	NSError *err;
	NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
	
	NSString *response;
	if (!err) {
		response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	} else {
		response = [@"fail|0" copy];
	}
	
	if ([@"success" isEqualToString:response]) {
		if (unsentMessages && [unsentMessages count]) {
			[[NSFileManager defaultManager] removeItemAtPath:unsentMessagesPath error:&err];
			[unsentMessages removeAllObjects];
		}
		if (unsentProperties && [unsentProperties count]) {
			if (!sentProperties) {
				sentProperties = [[NSMutableDictionary alloc] init];
			}
			
			for (ALProperty *property in [unsentProperties allValues]) {
				[sentProperties setObject:property forKey:property.name];
			}
			[NSKeyedArchiver archiveRootObject:sentProperties toFile:sentPropertiesPath];
			
			[[NSFileManager defaultManager] removeItemAtPath:unsentPropertiesPath error:&err];
			[unsentProperties removeAllObjects];
		}
	} else {
		if (newMessagesAdded) {
			[NSKeyedArchiver archiveRootObject:unsentMessages toFile:unsentMessagesPath];
			newMessagesAdded = NO;
		}
		if (newUnsentProperties) {
			[NSKeyedArchiver archiveRootObject:unsentProperties toFile:unsentPropertiesPath];
			newUnsentProperties = NO;
		}
	}
}

- (void)performStartupTasks {
	@synchronized(self) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		// fiksējam šī brīža situāciju
		ALAppUse *use = [[ALAppUse alloc] initWithCurrentDate];
		
		// ielādējam saglabāto informāciju
		[self loadSavedInfo];
		
		// pievienojam jauno lietošanas reizi
		if (!unsentMessages) {
			unsentMessages = [[NSMutableArray alloc] init];
		}
		[unsentMessages addObject:use];
		newMessagesAdded = YES;
		
		// nosūtam datus
		[self sendReport];
		
		[use release];
		
		[pool release];
	}
}

- (void) dealloc {
	[unsentMessagesPath release];
	[sentPropertiesPath release];
	[unsentPropertiesPath release];
	
	[sentProperties release];
	[unsentProperties release];

	[unsentMessages release];
	
	[super dealloc];
}

#pragma mark Īpašību uzstādīšana

- (void)setProperty:(ALProperty *)property {
	@synchronized(self) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

		BOOL propertyChanged = NO;
		if (sentProperties) {
			ALProperty *sentProperty = [sentProperties objectForKey:property.name];
			if (sentProperty) {
				propertyChanged = [property isValueChanged:sentProperty];
			} else {
				// ja īpašība nav nosūtīto sarakstā, tad tā noteikti ir jauna
				propertyChanged = YES;
			}
		} else {
			// ja nosūtīto īpašību saraksts ir tukšs, tad uzstādītā īpašība noteikti ir jauna
			propertyChanged = YES;
		}
		
		if (propertyChanged) {
			// īpašība ir jauna/mainīta
			if (!unsentProperties) {
				unsentProperties = [[NSMutableDictionary alloc] init];
			}
			[unsentProperties setObject:property forKey:property.name];
			newUnsentProperties = YES;
			
			// sūtam atskaiti
			[self sendReport];
		} else {
			// īpašība nav mainīta attiecībā jau pret nosūtīto vērtību
			// atceļam no sūtīšanas īpašību, ja rindā tāda ir ielikta
			if (unsentProperties) {
				[unsentProperties removeObjectForKey:property.name];
			}
		}
		
		[pool release];
	}
}

- (void)setObject:(id)object forProperty:(NSString *)propertyName {
	ALProperty *property = [[[ALProperty alloc] initWithName:propertyName value:object] autorelease];
	[self performSelectorInBackground:@selector(setProperty:) withObject:property];
}

- (void)setInteger:(NSInteger)value forProperty:(NSString *)propertyName {
	ALProperty *property = [[[ALProperty alloc] initWithName:propertyName value:[NSNumber numberWithInteger:value]] autorelease];
	[self performSelectorInBackground:@selector(setProperty:) withObject:property];
}

@end
