//
//  LJFriendGroup.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.21.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LJFriendGroup : NSObject<NSCoding> {
	NSUInteger groupID;
	NSString *name;
	NSUInteger sortOrder;
	BOOL publicGroup;
}

@property (readonly) NSUInteger groupID;
@property (readonly) NSString *name;
@property (readonly) NSUInteger sortOrder;
@property (readonly) BOOL publicGroup;

- (id)initWithID:(NSUInteger)groupID name:(NSString *)name sortOrder:(NSUInteger)sortOrder publicGroup:(BOOL)publicGroup;

@end
