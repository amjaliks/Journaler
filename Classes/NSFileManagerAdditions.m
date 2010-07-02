//
//  NSFileManagerAdditions.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.06.02.
//  Copyright 2010 A25. All rights reserved.
//

#import "NSFileManagerAdditions.h"


@implementation NSFileManager (NSFileManagerAdditions)

+ (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)directory {
	NSString *path = [NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES) lastObject];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	return path;
}

+ (NSString *)applicationSupportDirectoryPath {
	return [NSFileManager findOrCreateDirectory:NSApplicationSupportDirectory];
}

@end
