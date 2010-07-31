//
//  ErrorHandling.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.01.17.
//  Copyright 2010 A25. All rights reserved.
//

#import "ErrorHandler.h"
#import "SynthesizeSingleton.h"

#import "ErrorMessage.h"
#import "LiveJournal.h"

void showErrorMessage(NSString *title, NSString *text) {
	[[ErrorHandler sharedErrorHandler] showErrorMessage:text title:title];
}

NSString * decodeError(NSInteger code) {
	return [[ErrorHandler sharedErrorHandler] decodeError:code];
}

@implementation ErrorHandler

- (id)init {
	if (self = [super init]) {
		errorMessages = [[NSMutableArray alloc] init];
	}
	return self;
}

- (NSString *)decodeError:(NSInteger)code {
	NSString *text;
	if (LJErrorServerSide == code) {
		text = @"There is something wrong with the server.";
	} else if (LJErrorHostNotFound == code) {
		text = @"Can't find server.";
	} else if (LJErrorConnectionFailed == code) {
		text = @"Can't connect to server.";
	} else if (LJErrorNotConnectedToInternet == code) {
		text = @"Not connected to Internet.";
	} else if (LJErrorInvalidUsername == code) {
		text = @"Invalid username.";
	} else if (LJErrorInvalidPassword == code) {
		text = @"Invalid password.";
	} else if (LJErrorIncorrectTimeValue == code) {
		text = @"You have an entry with the date and time in future. Edit that entry to use the \"Date Out of Order\", before you can post a new post.";
	} else if (LJErrorMalformedRespone == code) {
		text = @"Can't understand server response. Please try again after a while!";
	} else if (LJErrorAccessIPBanDueLoginFailureRate == code) {
		text = @"Your IP address is temporarily banned for exceeding the login failure rate.";
	} else {
		text = [NSString stringWithFormat:@"Unknown error (%d).", code];
	}
	return text;
}

- (void)showErrorMessage:(NSString *)text title:(NSString *)title {
	[[[[UIAlertView alloc] initWithTitle:title message:text delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)showErrorMessageForAccount:(LJAccount *)account text:(NSString *)text title:(NSString *)title {
	if (account == visibleAccount) {
		[self showErrorMessage:text title:title];
	} else {
		[errorMessages addObject:[ErrorMessage errorMessage:text title:title account:account]];
	}
}

- (void)viewDidAppearForAccount:(LJAccount *)account {
	visibleAccount = account;
	for (ErrorMessage *errorMessage in [errorMessages copy]) {
		if (errorMessage.account == account) {
			[self showErrorMessage:errorMessage.message title:errorMessage.title];
			[errorMessages removeObject:errorMessage];
		}
	}
}

- (void)viewWillDisappear {
	visibleAccount = nil;
}

SYNTHESIZE_SINGLETON_FOR_CLASS(ErrorHandler)

@end

