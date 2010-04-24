//
//  LJMood.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 23.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LJMood : NSObject<NSCoding> {
	NSInteger ID;
	NSString *mood;
	
	NSUInteger hash;
}

@property (readonly, nonatomic) NSInteger ID;
@property (readonly, nonatomic) NSString *mood;

- (id)initWithID:(NSInteger)newID mood:(NSString *)newMood;
- (id)initWithMood:(NSString *)newMood;
- (NSComparisonResult)compare:(LJMood *)otherMood;

@end
