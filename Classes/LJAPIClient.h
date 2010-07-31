//
//  LJManager.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.21.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLJErrorDomain @"LJErrorDomain"
#define client [LJAPIClient sharedLJAPIClient]

@class LJAccount, LJSession, LJFriendGroup, LJEvent, LJComment;

@interface LJAPIClient : NSObject {

}

+ (LJAPIClient *)sharedLJAPIClient;

#pragma mark "Lietderīgās" metodes
- (NSString *)challengeForAccount:(LJAccount *)account error:(NSError **)error;
- (BOOL)loginForAccount:(LJAccount *)account error:(NSError **)error;
- (LJSession *)generateSessionForAccount:(LJAccount *)account error:(NSError **)error;
- (NSArray *)friendsPageEventsForAccount:(LJAccount *)account lastSync:(NSDate *)lastSync error:(NSError **)error;
- (BOOL)friendGroupsForAccount:(LJAccount *)account error:(NSError **)error;
- (BOOL)userTagsForAccount:(LJAccount *)account error:(NSError **)error;
- (BOOL)postEvent:(LJEvent *)event forAccount:(LJAccount *)account error:(NSError **)error;
- (BOOL)addComment:(LJComment *)comment forAccount:(LJAccount *)account error:(NSError **)error;

#pragma mark Tehniskās metodes
- (NSDictionary *)sendRequestToServer:(NSString *)server method:(NSString *)method parameters:(NSDictionary *)parameters error:(NSError **)error;
- (NSMutableDictionary *)newParametersForAccount:(LJAccount *)account challenge:(NSString *)challenge;
- (NSString *)readStringValue:(id)value;
- (NSArray *)readArrayOfStrings:(NSArray *)array;
- (NSArray *)friendGroupsFromArray:(NSArray *)array;

@end
