//
//  Error.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.29.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveJournal.h"

@interface ErrorMessage : NSObject {
	NSString *title;
	NSString *message;
	LJAccount *account;
}

@property (readonly) NSString *title;
@property (readonly) NSString *message;
@property (readonly) LJAccount *account;

+ (ErrorMessage *)errorMessage:(NSString *)message title:(NSString *)title account:(LJAccount *)account;
- (id)initWithMessage:(NSString *)message title:(NSString *)title account:(LJAccount *)account;

@end
