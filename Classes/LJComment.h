//
//  LJComment.h
//  Journaler
//
//  Created by Natālija Dudareva on 7/7/10.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LJComment : NSObject {
	NSString *commentBody;
	NSString *journal;
	NSNumber *ditemid;
}

@property (nonatomic, retain) NSString *commentBody;
@property (nonatomic, retain) NSString *journal;
@property (nonatomic, retain) NSNumber *ditemid;

@end
