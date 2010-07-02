//
//  NSStringLJ.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.01.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (NSStringLJ) 

- (NSString *)removeTag:(NSString *)tag replacement:(NSString *)replacement format:(NSString *)format;

@end
