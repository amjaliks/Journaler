//
//  Post.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.17.
//  Copyright 2009 A25. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Post : NSManagedObject {
	NSString *uniqueKey;

	NSString *textPreview;
	NSString *textView;
	NSString *subjectPreview;
	NSString *userPicURLHash;
	UIImage *userPic;
	
	UIView *view;
	NSUInteger posterNameWidth;
	BOOL updated;
	BOOL rendered;
}

@property (nonatomic, retain) NSString * journal;
@property (nonatomic, retain) NSNumber * journalType;
@property (nonatomic, retain) NSString * journalTypeOld;
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
@property (nonatomic, retain) NSNumber * parserVersion;
@property (nonatomic, retain) NSString * parsedSubjectPreview;
@property (nonatomic, retain) NSString * parsedSubjectView;
@property (nonatomic, retain) NSString * parsedTextPreview;
@property (nonatomic, retain) NSString * parsedTextView;

@property (readonly) NSString * uniqueKey;

@property (readonly) NSString * textPreview;
@property (readonly) NSString * textView;
@property (readonly) NSString * subjectPreview;
@property (readonly) NSString * userPicURLHash;
@property (retain) UIImage * userPic;
@property (readonly) BOOL isPublic;

@property (retain) UIView *view;
@property NSUInteger posterNameWidth;
@property BOOL updated;
@property BOOL rendered;

- (void) clearPreproceedStrings;

@end



