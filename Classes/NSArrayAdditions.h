//
//  NSArrayAdditions.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 21.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (NSArrayAdditions)

- (BOOL)containsTag:(NSString *)tag;

@end


@interface NSMutableArray (NSMutableArrayAdditions)

- (void)addTag:(NSString *)tag;

@end
