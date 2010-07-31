//
//  Error.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.29.
//  Copyright 2010 A25. All rights reserved.
//

#import "ErrorMessage.h"


@implementation ErrorMessage

@synthesize title;
@synthesize message;
@synthesize account;

+ (ErrorMessage *)errorMessage:(NSString *)message title:(NSString *)title account:(LJAccount *)account{
	return [[[ErrorMessage alloc] initWithMessage:message title:title account:account] autorelease];
}

- (id)initWithMessage:(NSString *)newMessage title:(NSString *)newTitle account:(LJAccount *)newAccount{
	if (self = [self init]) {
		message = newMessage;
		title = newTitle;
		account = newAccount;
	}
	return self;
}

@end
