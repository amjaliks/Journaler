//
//  LJAccount.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.22.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PostOptionsController.h"

@interface LJAccount : NSObject<NSCoding> {
	NSString *user;
	NSString *password;
	NSString *server;
	
	NSArray *communities;
	NSArray *friendGroups;
	
	NSString *text;
	NSString *subject;
	NSString *journal;
	PostSecurityLevel security;
	BOOL promote;
	
	NSUInteger selectedTab;
	NSUInteger scrollPosition;
	
	BOOL synchronized;
}

@property (retain) NSString *user;
@property (retain) NSString *password;
@property (retain) NSString *server;
@property (retain) NSArray *communities;
@property (retain) NSArray *friendGroups;

@property (retain) NSString *text;
@property (retain) NSString *subject;
@property (retain) NSString *journal;
@property PostSecurityLevel security;
@property BOOL promote;

@property NSUInteger selectedTab;

@property BOOL synchronized;

@property (readonly) NSString *title;

@end
