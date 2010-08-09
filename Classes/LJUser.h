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
	NSString *identity_type;
	NSString *identity_value;
	NSString *identity_display;
	NSString *fgcolor;
	NSString *bgcolor;
	NSString *groupmask;
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *fullname;
@property (nonatomic, retain) NSString *identity_type;
@property (nonatomic, retain) NSString *identity_value;
@property (nonatomic, retain) NSString *identity_display;
@property (nonatomic, retain) NSString *fgcolor;
@property (nonatomic, retain) NSString *bgcolor;
@property (nonatomic, retain) NSString *groupmask;

@end
