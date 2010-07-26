//
//  LiveJournal.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.02.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LJAccount.h"
#import "LJFriendGroup.h"
#import "LJEvent.h"
#import "LJAPIClient.h"
#import "LJMood.h"
#import "LJTag.h"
#import "LJComment.h"

enum {
	LJErrorUnknown = -1,
	LJErrorHostNotFound = -2,
	LJErrorConnectionFailed = -3,
	LJErrorServerSide = -6,
	LJErrorClientSide = -7,
	LJErrorNotConnectedToInternet = -8,
	LJErrorMalformedRespone = -9,
	LJErrorInvalidUsername = 100,
	LJErrorInvalidPassword = 101,
	LJErrorIncorrectTimeValue = 153,
	LJErrorAccessIPBanDueLoginFailureRate = 402
};

