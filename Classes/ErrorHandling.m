//
//  ErrorHandling.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.01.17.
//  Copyright 2010 A25. All rights reserved.
//

#import "ErrorHandling.h"
#import "LiveJournal.h"

void showErrorMessage(NSString *title, NSString *text) {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

NSString * decodeError(NSInteger code) {
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
	} else if (LJErrorMalformedRespone == code) {
		text = @"Can't understand server response.";
	} else if (LJErrorAccessIPBanDueLoginFailureRate == code) {
		text = @"Your IP address is temporarily banned for exceeding the login failure rate.";
	} else {
		text = [NSString stringWithFormat:@"Unknown error (%d).", code];
	}
	return text;
}
