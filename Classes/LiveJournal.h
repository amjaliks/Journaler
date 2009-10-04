//
//  LiveJournal.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.02.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJAccount : NSObject {
	NSString *user;
	NSString *password;
	NSString *server;
}

@property NSString *user;
@property NSString *password;
@property NSString *server;

@end


@interface LJFlatRequest : NSObject {
	NSString *_server;
	NSString *_mode;
	
	NSMutableDictionary *parameters;
	NSMutableDictionary *result;
}

- (id)initWithServer:(NSString *)server mode:(NSString *)mode;
- (BOOL)doRequest;

@property (readonly) BOOL success;

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