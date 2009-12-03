//
//  LiveJournal.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.02.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PostOptionsController.h"

NSString* md5(NSString *str);

enum {
	LJErrorUnknown = -1,
	LJErrorHostNotFound = -2,
	LJErrorConnectionFailed = -3,
	LJErrorServerSide = -6,
	LJErrorClientSide = -7,
	LJErrorNotConnectedToInternet = -8,
	LJErrorInvalidUsername = 100,
	LJErrorInvalidPassword = 101,
	LJErrorAccessIPBanDueLoginFailureRate = 402
};


// LJ server account info
@interface LJAccount : NSObject<NSCoding> {
	NSString *user;
	NSString *password;
	NSString *server;
	
	NSArray *communities;
	
	NSString *text;
	NSString *subject;
	NSString *journal;
	PostSecurityLevel security;
	BOOL promote;
	
	NSUInteger selectedTab;
	
	BOOL synchronized;
}

@property (retain) NSString *user;
@property (retain) NSString *password;
@property (retain) NSString *server;
@property (retain) NSArray *communities;

@property (retain) NSString *text;
@property (retain) NSString *subject;
@property (retain) NSString *journal;
@property PostSecurityLevel security;
@property BOOL promote;

@property NSUInteger selectedTab;

@property BOOL synchronized;

@property (readonly) NSString *title;

@end

@interface LJEvent : NSObject {
	NSString *journalName;
	NSString *journalType;
	NSString *posterName;
	NSString *posterType;
	NSString *subject;
	NSString *event;
	NSDate *datetime;
	NSUInteger replyCount;
	NSString *eventPreview;
	NSString *eventView;
	NSString *userPicUrl;
	NSNumber *ditemid;
	NSString *security;
}

@property (retain) NSString *journalName;
@property (retain) NSString *journalType;
@property (retain) NSString *posterName;
@property (retain) NSString *posterType;
@property (retain) NSString *subject;
@property (retain) NSString *event;
@property (retain) NSDate *datetime;
@property NSUInteger replyCount;
@property (readonly) NSString *eventPreview;
@property (readonly) NSString *eventView;
@property (retain) NSString *userPicUrl;
@property (retain) NSNumber *ditemid;
@property (retain) NSString *security;

+ (NSString *) removeTagFromString:(NSString *)string tag:(NSString *)tag replacement:(NSString *)replacement format:(NSString *)format;

@end


// A raw object for LJ Flat API request. Use as superclass for all requests.
//@interface LJFlatRequest : NSObject {
//	NSString *_server;
//	NSString *_mode;
//	
//	NSMutableDictionary *parameters;
//	NSMutableDictionary *result;
//	
//	NSUInteger error;
//}
//
//- (id)initWithServer:(NSString *)server mode:(NSString *)mode;
//- (BOOL)doRequest;
//- (void)proceedError;
//
//@property (readonly) BOOL success;
//@property (readonly) NSUInteger error;
//
//@end


@interface LJRequest : NSObject {
	NSString *_server;
	NSString *_method;
	
	NSMutableDictionary *parameters;
	NSMutableDictionary *result;
	
	NSUInteger error;
}

+ (id)proceedRawValue:(id)value;
- (id)initWithServer:(NSString *)server method:(NSString *)method;
- (BOOL)doRequest;

@property (readonly) BOOL success;
@property (readonly) NSUInteger error;

@end


//@interface LJFlatGetChallenge : LJFlatRequest {
//}
//
//+ (LJFlatGetChallenge *)requestWithServer:(NSString *)server;
//
//@property (readonly) NSString *challenge;
//
//@end


@interface LJGetChallenge : LJRequest {
}

+ (LJGetChallenge *)requestWithServer:(NSString *)server;

@property (readonly) NSString *challenge;

@end


@interface LJLogin : LJRequest {
	NSString *challenge;
	NSString *password;
	
	NSArray *usejournals;
}

@property (readonly) NSArray *usejournals;

+ (LJLogin *)requestWithServer:(NSString *)server user:(NSString *)user password:(NSString *)password challenge:(NSString *)challenge;

@end


@interface LJSessionGenerate : LJRequest {
	NSString *challenge;
	NSString *password;
}

+ (LJSessionGenerate *)requestWithServer:(NSString *)server user:(NSString *)user password:(NSString *)password challenge:(NSString *)challenge;

@property (readonly) NSString *ljsession;

@end


@interface LJPostEvent : LJRequest {
	NSString *challenge;
	NSString *password;
	
	NSString *usejournal;
	PostSecurityLevel security;
}

@property (retain) NSString *usejournal;
@property PostSecurityLevel security;

+ (LJPostEvent *)requestWithServer:(NSString *)server user:(NSString *)user password:(NSString *)password challenge:(NSString *)challenge subject:(NSString *)subject event:(NSString *)event;

@end


@interface LJGetFriendsPage : LJRequest {
	NSString *challenge;
	NSString *password;
	NSMutableArray *entries;
	
	NSDate *lastSync;
	NSNumber *itemShow;
	NSNumber *skip;
}

+ (LJGetFriendsPage *)requestWithServer:(NSString *)server user:(NSString *)user password:(NSString *)password challenge:(NSString *)challenge;

@property (readonly) NSArray *entries;
@property (retain) NSDate *lastSync;
@property (retain) NSNumber *itemShow;
@property (retain) NSNumber *skip;

@end

//@interface LJFlatGetEvents : LJFlatRequest {
//	NSString *challenge;
//	NSString *password;
//	NSMutableArray *entries;
//}
//
//+ (LJFlatGetEvents *)requestWithServer:(NSString *)server user:(NSString *)user password:(NSString *)password challenge:(NSString *)challenge;
//
//@property (readonly) NSArray *entries;
//
//@end
