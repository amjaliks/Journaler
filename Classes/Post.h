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
}

@property (nonatomic, retain) NSString * journal;
@property (nonatomic, retain) NSString * journalType;
@property (nonatomic, retain) NSDate * dateTime;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain, readonly) NSString * textPreview;
@property (nonatomic, retain) NSString * poster;
@property (nonatomic, retain) NSNumber * replyCount;
@property (nonatomic, retain, readonly) NSString * textView;
@property (nonatomic, retain) NSString * account;
@property (nonatomic, retain) NSNumber * ditemid;
@property (nonatomic, retain) NSString * userPicURL;
@property (nonatomic, retain) NSNumber * isRead;

@end



