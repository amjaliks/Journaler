//
//  Post.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.17.
//  Copyright 2009 A25. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Post :  NSManagedObject {
	NSString *textPreview;
	NSString *textView;
	NSString *subjectPreview;
	
	NSUInteger posterNameWidth;
	BOOL updated;
}

@property (nonatomic, retain) NSString * journal;
@property (nonatomic, retain) NSString * journalType;
@property (nonatomic, retain) NSDate * dateTime;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSString * poster;
@property (nonatomic, retain) NSNumber * replyCount;
@property (nonatomic, retain) NSString * account;
@property (nonatomic, retain) NSNumber * ditemid;
@property (nonatomic, retain) NSString * userPicURL;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString * security;

@property (readonly) NSString * textPreview;
@property (readonly) NSString * textView;
@property (readonly) NSString * subjectPreview;
@property (readonly) BOOL isPublic;

@property NSUInteger posterNameWidth;
@property BOOL updated;

- (void) clearPreproceedStrings;

@end



