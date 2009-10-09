//
//  LiveJournal.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.02.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


enum {
	LJErrorUnknown = 1,
	LJErrorHostNotFound,
	LJErrorConnectionFailed,
	LJErrorInvalidUsername,
	LJErrorInvalidPassword
};


// LJ server account info
@interface LJAccount : NSObject<NSCoding> {
	NSString *user;
	NSString *password;
	NSString *server;
}

@property (retain) NSString *user;
@property (retain) NSString *password;
@property (retain) NSString *server;

@property (readonly) NSString *title;

@end


// A raw object for LJ Flat API request. Use as superclass for all requests.
@interface LJFlatRequest : NSObject {
	NSString *_server;
	NSString *_mode;
	
	NSMutableDictionary *parameters;
	NSMutableDictionary *result;
	
	NSUInteger error;
}

- (id)initWithServer:(NSString *)server mode:(NSString *)mode;
- (BOOL)doRequest;
- (void)proceedError;

@property (readonly) BOOL success;
@property (readonly) NSUInteger error;

@end


@interface LJFlatGetChallenge : LJFlatRequest {
}

+ (LJFlatGetChallenge *)requestWithServer:(NSString *)server;

@property (readonly) NSString *challenge;

@end


@interface LJFlatLogin : LJFlatRequest {
	NSString *challenge;
	NSString *password;
}

+ (LJFlatLogin *)requestWithServer:(NSString *)server user:(NSString *)user password:(NSString *)password challenge:(NSString *)challenge;

@end


@interface LJFlatSessionGenerate : LJFlatRequest {
	NSString *challenge;
	NSString *password;
}

+ (LJFlatSessionGenerate *)requestWithServer:(NSString *)server user:(NSString *)user password:(NSString *)password challenge:(NSString *)challenge;

@property (readonly) NSString *ljsession;

@end


@interface LJFlatPostEvent : LJFlatRequest {
	NSString *challenge;
	NSString *password;
}

+ (LJFlatPostEvent *)requestWithServer:(NSString *)server user:(NSString *)user password:(NSString *)password challenge:(NSString *)challenge subject:(NSString *)subject event:(NSString *)event;

@end
