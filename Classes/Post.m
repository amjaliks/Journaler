// 
//  Post.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.17.
//  Copyright 2009 A25. All rights reserved.
//

#import "Post.h"
#import "LiveJournal.h"
#import "RegexKitLite.h"

@implementation Post 

@dynamic journal;
@dynamic journalType;
@dynamic dateTime;
@dynamic text;
@dynamic subject;
@dynamic poster;
@dynamic replyCount;
@dynamic account;
@dynamic ditemid;
@dynamic userPicURL;

- (NSString *)textPreview {
	if (!textPreview) {
		textPreview = [self.text retain];
		
		NSRange notFoundRange;
		notFoundRange.location = NSNotFound;
		notFoundRange.length = 0;
		
		NSRange forward;
		forward.location = 0;
		forward.length = [textPreview length];
		
		textPreview = [LJEvent removeTagFromString:textPreview tag:@"<lj user=\".+?\">" replacement:@"\"(.+?)\"" format:nil];
		textPreview = [LJEvent removeTagFromString:textPreview tag:@"<lj-cut text=\".+?\">.*?</lj-cut>" replacement:@"text=\"(.+?)\"" format:@"( %@ )"];
		textPreview = [textPreview stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
		textPreview = [textPreview stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
		textPreview = [textPreview stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
		
		NSMutableString *meventPreview = [NSMutableString stringWithString:textPreview];
		
		[meventPreview replaceOccurrencesOfRegex:@"<br\\s*/?>" withString:@" " options:(RKLDotAll | RKLCaseless) range:NSMakeRange(0, [meventPreview length]) error:nil];
		[meventPreview replaceOccurrencesOfRegex:@"<img\\s?.*?/?>" withString:@"( img )" options:(RKLDotAll | RKLCaseless) range:NSMakeRange(0, [meventPreview length]) error:nil];
		[meventPreview replaceOccurrencesOfRegex:@"<.+?>" withString:@""  options:(RKLDotAll | RKLCaseless)range:NSMakeRange(0, [meventPreview length]) error:nil];
		[meventPreview replaceOccurrencesOfRegex:@"&.+?;" withString:@""  options:(RKLDotAll | RKLCaseless)range:NSMakeRange(0, [meventPreview length]) error:nil];
		
		textPreview = [meventPreview retain];
	}
	return textPreview;
}

- (NSString *)textView {
	if (!textView) {
		textView = [self.text retain];
		
		NSRange notFoundRange;
		notFoundRange.location = NSNotFound;
		notFoundRange.length = 0;
		
		NSRange forward;
		forward.location = 0;
		forward.length = [textView length];
		
		textView = [LJEvent removeTagFromString:textView tag:@"<lj user=\".+?\">" replacement:@"\"(.+?)\"" format:nil];
		textView = [LJEvent removeTagFromString:textView tag:@"<img\\s?.*?/?>" replacement:@"src=\"(.+?)\"" format:@"( <a href=\"%@\">img</a> )"];
				
		textView = [textView stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
		
		[textView retain];
	}
	
	return textView;
}

@end
