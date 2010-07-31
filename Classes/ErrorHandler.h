//
//  ErrorHandling.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.01.17.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveJournal.h"

#define errorHandler [ErrorHandler sharedErrorHandler]

void showErrorMessage(NSString *title, NSString *text);
NSString * decodeError(NSInteger code);

@interface ErrorHandler : NSObject {
	LJAccount *visibleAccount;
	NSMutableArray *errorMessages;
}

+ (ErrorHandler *)sharedErrorHandler;
- (NSString *)decodeError:(NSInteger)code;
- (void)showErrorMessage:(NSString *)text title:(NSString *)title;
- (void)showErrorMessageForAccount:(LJAccount *)account text:(NSString *)text title:(NSString *)title;
- (void)viewDidAppearForAccount:(LJAccount *)account;
- (void)viewWillDisappear;

@end

