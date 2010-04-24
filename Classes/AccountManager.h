//
//  AccountManager.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.01.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kStateInfoFileName @"stateInfo.plist"
#define kStateInfoOpenedAccount @"opened_account"
#define kStateInfoAccounts @"accounts"
#define kStateInfoOpenedScreenType @"opened_screen_type"
#define kStateInfoFirstVisiblePost @"first_visible_post" 
#define kStateInfoFirstVisiblePostScrollPosition @"first_visible_post_scroll_position" 
#define kStateInfoLastVisiblePostIndex @"last_visible_post_index"
#define kStateInfoOpenedPost @"opened_post"
#define kStateInfoNewPostText @"new_post_text"
#define kStateInfoNewPostSubject @"new_post_subject"
#define kStateInfoNewPostSecurity @"new_post_security"
#define kStateInfoNewPostSelectedFriendGroups @"new_post_selected_friend_groups"
#define kStateInfoNewPostJournal @"new_post_journal"
#define kStateInfoNewPostPicKeyword @"new_post_pic_keyword"
#define kStateInfoNewPostTags @"new_post_tags"
#define kStateInfoNewPostMood @"new_post_mood"
#define kStateInfoNewPostPromote @"new_post_promote"

@class LJAccount, PostEditorController;

typedef enum {
	OpenedScreenFriendsPage = 0,
	OpenedScreenPost = 1,
	OpenedScreenNewPost = 2
} OpenedScreenType;

@interface AccountManager : NSObject {
	NSMutableArray *accounts;
	NSMutableDictionary *accountsDict;
	
	NSMutableDictionary *stateInfo;
	
	NSMutableArray *postEditors;
}

+ (AccountManager *)sharedManager;

// kontu pārvaldīšana
- (void)loadAccounts;
- (void)storeAccounts;
- (NSMutableArray *)accounts;
- (LJAccount *)accountForKey:(NSString *)key;
#ifdef LITEVERSION
- (LJAccount *)account;
- (void)storeAccount:(LJAccount *)account;
#endif

// stāvokļa pārvaldīšana
- (void)loadScreenState;
- (void)storeScreenState;
- (NSMutableDictionary *)stateInfo;
- (void)registerPostEditorController:(PostEditorController *)controller;

// nolasīšana
- (id)valueForPath:(NSArray *)path;
- (NSUInteger)unsignedIntegerValueForPath:(NSArray *)path;

- (id)valueForAccount:(NSString *)account forKey:(NSString *)key;
- (BOOL)boolValueForAccount:(NSString *)account forKey:(NSString *)key defaultValue:(BOOL)defaultValue;
- (NSSet *)setForAccount:(NSString *)account forKey:(NSString *)key;
- (NSUInteger)unsignedIntegerValueForAccount:(NSString *)account forKey:(NSString *)key;

- (NSString *)openedAccount;

// uzstādīšana
- (void)setValue:(id)value forPath:(NSArray *)path;

- (void)setValue:(id)value forAccount:(NSString *)account forKey:(NSString *)key;
- (void)setBoolValue:(BOOL)value forAccount:(NSString *)account forKey:(NSString *)key;
- (void)setSet:(NSSet *)set forAccount:(NSString *)account forKey:(NSString *)key;
- (void)setUnsignedIntegerValue:(NSUInteger)value forAccount:(NSString *)account forKey:(NSString *)key;

- (void)setOpenedAccount:(NSString *)account;

// dzēšana
- (void)removeStateForAccount:(NSString *)account;

@end
