//
//  NSArrayAdditions.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 21.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSSet (NSSetAdditions)

- (BOOL)containsTag:(NSString *)tag;
- (NSArray *)sortedArray;

@end


@interface NSMutableSet (NSMutableSetAdditions)

- (void)addTag:(NSString *)tag;
- (void)addObjectsFromSet:(NSSet *)set;

@end
