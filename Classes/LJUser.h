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
	NSMutableArray *group;
}

@property (readonly) NSString *username;
@property (readonly) NSMutableArray *group;

- (id)initWithUsername:(NSString *)name group:(NSMutableArray *)group;

@end
