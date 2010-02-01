//
//  AccountManager.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.01.
//  Copyright 2010 A25. All rights reserved.
//

#import "AccountManager.h"
#import "Macros.h"
#import "LiveJournal.h"

#define kAccountsFileName @"accounts.bin"
#define kAccountFileName @"account.bin"

static AccountManager *sharedManager;

@implementation AccountManager

#pragma mark Kontu pārvaldīšana

- (void)loadAccounts {
	// nolasam kontu sarakstu
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];
	path = [path stringByAppendingPathComponent:kAccountsFileName];
	accounts = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	
#ifdef LITEVERSION
	// migrējam veco LITE kontu glabāšanu uz kopīgo abām versijām
	if (!accounts) {
		path = [[paths objectAtIndex:0] stringByAppendingPathComponent:kAccountFileName];
		LJAccount *account = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
		if (account) {
			accounts = [NSArray arrayWithObjects:account, nil];
			NSError *error;
			[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
		}
	}
#endif
	
	if (accounts) {
		// ja saraksts veiksmīgi ielādēts, tad veicam dažas tehniskas darbības
		accounts = [accounts mutableCopy];
		accountsDict = [[NSMutableDictionary alloc] initWithCapacity:[accounts count]];
		for (LJAccount *account in accounts) {
			[accountsDict setObject:account forKey:account.title];
		}
	} else {
		// ja saraksts nav ielādēts, tad izveidojam tukšu masīvu
		accounts = [[NSMutableArray alloc] initWithCapacity:1];
		accountsDict = [[NSMutableDictionary alloc] initWithCapacity:1];
	}
}

- (void)storeAccounts {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];
	path = [path stringByAppendingPathComponent:kAccountsFileName];
	[NSKeyedArchiver archiveRootObject:accounts toFile:path];
}

- (NSMutableArray *)accounts {
	return accounts;
}

- (LJAccount *)accountForKey:(NSString *)key {
	return [accountsDict objectForKey:key];
}

#ifdef LITEVERSION
- (LJAccount *)account {
	return [accounts lastObject];
}

- (void)storeAccount:(LJAccount *)account {
	[accounts removeAllObjects];
	[accountsDict removeAllObjects];
	
	[accounts addObject:account];
	[accountsDict setObject:account forKey:account.title];
	[self storeAccounts];
}
#endif

#pragma mark Ekrānu stāvokļa pārvaldīšana

- (void)loadScreenState {
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSString *plistPath = [APP_CACHES_DIR stringByAppendingPathComponent:kStateInfoFileName];
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	if (plistXML) {
		id temp = [NSPropertyListSerialization
											  propertyListFromData:plistXML
											  mutabilityOption:NSPropertyListMutableContainersAndLeaves
											  format:&format
											  errorDescription:&errorDesc];
		if (temp && [temp isKindOfClass:[NSMutableDictionary class]]) {
			stateInfo = [temp retain];
		} else {
			NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
		}
	}
}

- (void)storeScreenState {
    NSString *error;
    NSString *plistPath = [APP_CACHES_DIR stringByAppendingPathComponent:kStateInfoFileName];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:[self stateInfo]
																   format:NSPropertyListBinaryFormat_v1_0
														 errorDescription:&error];
    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
    } else {
        NSLog(error);
        [error release];
    }
}

- (NSMutableDictionary *)stateInfo {
	if (!stateInfo) {
		stateInfo = [[NSMutableDictionary alloc] init];
	}
	return stateInfo;
}

- (id)valueForPath:(NSArray *)path {
	id obj = [self stateInfo];
	for (NSString *name in path) {
		obj = [obj objectForKey:name];
		if (!obj) {
			return nil;
		}
	}
	return obj;
}

- (NSString *)openedAccount {
	return [[self stateInfo] objectForKey:kStateInfoOpenedAccount];
}

- (NSString *)firstVisiblePostForAccount:(NSString *)key {
	return [self valueForPath:[NSArray arrayWithObjects:kStartInfoAccounts, key, kStateInfoFirstVisiblePost, nil]];
}

- (NSUInteger)scrollPositionForOpenedPostForAccount:(NSString *)account {
	NSNumber *number = [self valueForPath:[NSArray arrayWithObjects:kStartInfoAccounts, account, kStateInfoFirstVisiblePostScrollPosition, nil]];
	if (number) {
		return [number unsignedIntegerValue];
	} else {
		return 0;
	}
}

- (void)setValue:(id)value forPath:(NSArray *)path {
	NSMutableDictionary *dict = stateInfo;
	
	NSUInteger i = 0;
	for (NSString *name in path) {
		i++;
		if (i == [path count]) {
			break;
		} else {
			NSMutableDictionary *nextDict = [dict objectForKey:name];
			if (!nextDict) {
				nextDict = [[NSMutableDictionary alloc] initWithCapacity:1];
				[dict setObject:nextDict forKey:name];
			}
			dict = nextDict;
		}
	}
	
	[dict setValue:value forKey:[path lastObject]];
}

- (void)setOpenedAccount:(NSString *)account {
	if (account) {
		[[self stateInfo] setObject:account forKey:kStateInfoOpenedAccount];
	} else {
		[[self stateInfo] removeObjectForKey:kStateInfoOpenedAccount];
	}
}

- (void)setFirstVisiblePost:(NSString *)post forAccount:(NSString *)account {
	[self setValue:post forPath:[NSArray arrayWithObjects:kStartInfoAccounts, account, kStateInfoFirstVisiblePost, nil]];
}

- (void)setScrollPosition:(NSUInteger)position forFirstVisiblePostForAccount:(NSString *)account {
	[self setValue:[NSNumber numberWithUnsignedInteger:position] forPath:[NSArray arrayWithObjects:kStartInfoAccounts, account, kStateInfoFirstVisiblePostScrollPosition, nil]];
}

#pragma mark Atmiņas pārvaldīšana

- (void)dealloc {
	[accounts release];
	[accountsDict release];
	[stateInfo release];
	
	[super dealloc];
}


#pragma mark Singleton metodes

+ (AccountManager *)sharedManager {
	@synchronized (self) {
		if (sharedManager == nil) {
			sharedManager = [[super allocWithZone:nil] init];
		}
	}
	return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedManager] retain];
}

- (id)init {
	self = [super init];
	if (self != nil) {
		stateInfo = nil;
	}
	return self;
}


- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
