//
//  ALAppUse.h
//  Appnlytics
//
//  Created by Aleksejs Mjaliks on 09.11.03.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ALAppUse : NSObject <NSCoding> {
	//NSString *appVersion;
	NSDate *date;
}

//@property (readonly) NSString *appVersion;
@property (readonly) NSDate *date;

- (id)initWithCurrentDate;

@end
