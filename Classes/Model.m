//
//  Model.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.17.
//  Copyright 2009 A25. All rights reserved.
//

#import "Model.h"


@implementation Model

- (void)saveAll {
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			[NSException raise:@"Failed to save persistent store" format:@"Error info: domain: %@; code: %d", [error domain], [error code]];
        } 
    }
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	NSString *storePath = [[self applicationCachesDirectory] stringByAppendingPathComponent: @"postcache.sqlite"];
    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	NSError *error = nil;
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, nil];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
		// ja gadījusies kļūda, tad cenšamies izdzēst kešu ..
		[[NSFileManager defaultManager] removeItemAtPath:storePath error:nil];
		
		// ..  un mēģinam vēlreiz
		if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
			[NSException raise:@"Can't open persistent store" format:@"Error info: domain: %@; code: %d", [error domain], [error code]];
		}
    }    
	
    return persistentStoreCoordinator;
}

- (NSString *)applicationCachesDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark Post

- (Post *)createPost {
	Post *post = (Post *)[NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:self.managedObjectContext];
	return post;
}

- (NSArray *)findPostsByAccount:(NSString *)account {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:self.managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(account = %@)", account];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:NO];
	[request setEntity:entity];
	[request setPredicate:predicate];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	NSError *error;
	NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (!result) {
		[NSException raise:@"Failed to perform request" format:@"Error info: domain: %@; code: %d", [error domain], [error code]];
	}
	[request release];
	return result;
}

- (NSArray *)findPostsByAccount:(NSString *)account limit:(NSUInteger)limit offset:(NSUInteger)offset {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:self.managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(account = %@)", account];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:NO];
	[request setEntity:entity];
	[request setPredicate:predicate];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	[request setFetchLimit:limit];
	[request setFetchOffset:offset];
	
	NSError *error;
	NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (!result) {
		[NSException raise:@"Failed to perform request" format:@"Error info: domain: %@; code: %d", [error domain], [error code]];
	}
	[request release];
	return result;
}

- (Post *)findPostByAccount:(NSString *)account journal:(NSString *)journal dItemId:(NSNumber *)dItemId {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:self.managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(account = %@) AND (journal = %@) AND (ditemid = %@)", account, journal, dItemId];
	[request setEntity:entity];
	[request setPredicate:predicate];
	
	NSError *error;
	NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (!result) {
		[NSException raise:@"Failed to perform request" format:@"Error info: domain: %@; code: %d", [error domain], [error code]];
	}
	[request release];
	if ([result count]) {
		return [result lastObject];
	} else {
		return nil;
	}
}

- (void)deletePost:(Post *)post {
	[self.managedObjectContext deleteObject:post];
}

- (void)deleteAllPostsForAccount:(NSString *)account {
	NSArray *posts = [self findPostsByAccount:account];
	for (Post *post	in posts) {
		[self deletePost:post];
	}
}

#pragma mark Memory managment

- (void) dealloc {
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
	
	[super dealloc];
}

@end
