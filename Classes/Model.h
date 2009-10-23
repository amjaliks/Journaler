//
//  Model.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.17.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Post.h"

@interface Model : NSObject {
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;	
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationCachesDirectory;

- (void)saveAll;

- (Post *)createPost;
- (NSArray *)findPostsByAccount:(NSString *)account;
- (Post *)findPostByAccount:(NSString *)account journal:(NSString *)journal dItemId:(NSNumber *)dItemId;
- (void)deletePost:(Post *)post;
- (void)deleteAllPostsForAccount:(NSString *)account;

@end
