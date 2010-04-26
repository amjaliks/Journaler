//
//  LJTag.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 24.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LJTag : NSObject {
	NSString *name;
	
	NSUInteger hash;
}

@property (retain, nonatomic) NSString *name;

- (id)initWithName:(NSString *)newName;
- (NSComparisonResult)compare:(LJTag *)otherTag;

@end
