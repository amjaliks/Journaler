//
//  LJSession.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.28.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LJSession : NSObject {
	NSString *sessionID;
	NSDate *validTill;
}

@property (readonly) NSString *sessionID;
@property (readonly, getter=isValid) BOOL valid;

- (id)initWithID:(NSString *)sessionID;
- (BOOL)isValid;

@end
