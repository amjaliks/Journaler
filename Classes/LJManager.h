//
//  LJManager.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.21.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLJErrorDomain @"LJErrorDomain"

@class LJAccount, LJFriendGroup;

@interface LJManager : NSObject {

}

+ (LJManager *)defaultManager;

#pragma mark "Lietderīgās" metodes
- (NSString *)challengeForAccount:(LJAccount *)account error:(NSError **)error;
- (NSArray *)friendGroupsForAccount:(LJAccount *)account error:(NSError **)error;

#pragma mark Tehniskās metodes
- (NSDictionary *)sendRequestToServer:(NSString *)server method:(NSString *)method parameters:(NSDictionary *)parameters error:(NSError **)error;
- (NSMutableDictionary *)newParametersForAccount:(LJAccount *)account challenge:(NSString *)challenge;
- (NSString *)readStringValue:(id)value;
- (LJFriendGroup *)newFriendGroupFromDictionary:(NSDictionary *)dictionary;

@end
