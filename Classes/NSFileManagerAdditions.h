//
//  NSFileManagerAdditions.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.06.02.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSFileManager (NSFileManagerAdditions) 

+ (NSString *)findOrCreateDirectory:(NSSearchPathDirectory) directory;
+ (NSString *)applicationSupportDirectoryPath;

@end
