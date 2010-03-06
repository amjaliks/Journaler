//
//  LJManager.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.21.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLJErrorDomain @"LJErrorDomain"

@class LJAccount, LJFriendGroup, LJNewEvent;

@interface LJManager : NSObject {

}

+ (LJManager *)defaultManager;

#pragma mark "Lietderīgās" metodes
- (NSString *)challengeForAccount:(LJAccount *)account error:(NSError **)error;
- (BOOL)loginForAccount:(LJAccount *)account error:(NSError **)error;
- (BOOL)friendGroupsForAccount:(LJAccount *)account error:(NSError **)error;
- (BOOL)postEvent:(LJNewEvent *)event forAccount:(LJAccount *)account error:(NSError **)error;

#pragma mark Tehniskās metodes
- (NSDictionary *)sendRequestToServer:(NSString *)server method:(NSString *)method parameters:(NSDictionary *)parameters error:(NSError **)error;
- (NSMutableDictionary *)newParametersForAccount:(LJAccount *)account challenge:(NSString *)challenge;
- (NSString *)readStringValue:(id)value;
- (NSArray *)friendGroupsFromArray:(NSArray *)array;

@end