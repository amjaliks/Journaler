//
//  ALReporter.h
//  Appnlytics
//
//  Created by Aleksejs Mjaliks on 09.11.01.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALDeviceInfo;

@interface ALReporter : NSObject {
	NSString *appUID;
	NSURL *reportURL;
	
	// ceļi uz failiem
	NSString *unsentMessagesPath;
	NSString *sentPropertiesPath;
	NSString *unsentPropertiesPath;
	
	// nenosūtītā informācija
	NSMutableArray *unsentMessages;
	NSMutableDictionary *unsentProperties;
	
	// nosūtītā informācija
	NSMutableDictionary *sentProperties;
	
	ALDeviceInfo *currentDeviceInfo;
	
	// pazīme, ka informācija mainīta
	BOOL newMessagesAdded;
	BOOL newUnsentProperties;
}

- (id)initWithAppUID:(NSString *)appUID reportURL:(NSURL *)reportURL;

- (void)setObject:(id)object forProperty:(NSString *)property;
- (void)setInteger:(NSInteger)value forProperty:(NSString *)property;

@end
