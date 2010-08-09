//
//  LJUser.h
//  Journaler
//
//  Created by Natālija Dudareva on 8/9/10.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LJUser : NSObject {
	NSString *username;
	NSString *fullname;
	NSUInteger groupmask;
}

@property (readonly) NSString *username;
@property (readonly) NSString *fullname;
@property (readonly) NSUInteger groupmask;

- (id)initWithUsername:(NSString *)name group:(NSUInteger)groupmask;

@end
