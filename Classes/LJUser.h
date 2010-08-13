//
//  LJUser.h
//  Journaler
//
//  Created by Natālija Dudareva on 8/9/10.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LJUser : NSObject<NSCoding> {
	NSString *username;
	NSMutableArray *groups;
}

@property (readonly) NSString *username;
@property (readonly) NSMutableArray *groups;

- (id)initWithUsername:(NSString *)name groups:(NSMutableArray *)groups;

@end
