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
@dynamic isRead;

@synthesize posterNameWidth;
@synthesize updated;

- (NSString *)textPreview {
	@synchronized(self) {
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
			[meventPreview replaceOccurrencesOfRegex:@"<img\\s?.*?/?>" withString:@"image" options:(RKLDotAll | RKLCaseless) range:NSMakeRange(0, [meventPreview length]) error:nil];
			[meventPreview replaceOccurrencesOfRegex:@"<lj-embed .+?/>" withString:@"video" options:(RKLDotAll | RKLCaseless) range:NSMakeRange(0, [meventPreview length]) error:nil];
			[meventPreview replaceOccurrencesOfRegex:@"<.+?>" withString:@""  options:(RKLDotAll | RKLCaseless)range:NSMakeRange(0, [meventPreview length]) error:nil];
			[meventPreview replaceOccurrencesOfRegex:@"&.+?;" withString:@""  options:(RKLDotAll | RKLCaseless)range:NSMakeRange(0, [meventPreview length]) error:nil];
			
			textPreview = [meventPreview retain];
		}
	}
	return textPreview;
}

- (NSString *)textView {
	@synchronized (self) {
		if (!textView) {
			textView = [self.text mutableCopy];
			
			NSRange notFoundRange;
			notFoundRange.location = NSNotFound;
			notFoundRange.length = 0;
			
			NSRange forward;
			forward.location = 0;
			forward.length = [textView length];
			
			[((NSMutableString *)textView) replaceOccurrencesOfRegex:@"<lj-embed .+?/>" withString:@"@videoicon@ video" options:(RKLDotAll | RKLCaseless) range:NSMakeRange(0, [textView length]) error:nil];
			textView = [LJEvent removeTagFromString:textView tag:@"<lj user=\".+?\">" replacement:@"\"(.+?)\"" format:nil];
			textView = [LJEvent removeTagFromString:textView tag:@"<img\\s?.*?/?>" replacement:@"src=\"?(.+?)[\"|\\s|>]" format:@"<a href=\"%@\">@imageicon@ image</a>"];
			//textView = [LJEvent removeTagFromString:textView tag:@"<lj-embed .+?/>" replacement:@"youtube.com/v/(.+?)&" format:@"<a href=\"%@\">@videoicon@ video</a>"];
					
			textView = [textView stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
			
			[textView retain];
		}
	}
	return textView;
}

- (NSString *)subjectPreview {
	@synchronized(self) {
		if (!subjectPreview) {
			subjectPreview = [self.subject retain];
			
			NSRange notFoundRange;
			notFoundRange.location = NSNotFound;
			notFoundRange.length = 0;
			
			NSRange forward;
			forward.location = 0;
			forward.length = [textPreview length];
			
			subjectPreview = [subjectPreview stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
			subjectPreview = [subjectPreview stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
			subjectPreview = [subjectPreview stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
			
			NSMutableString *meventPreview = [NSMutableString stringWithString:subjectPreview];
			
			[meventPreview replaceOccurrencesOfRegex:@"<.+?>" withString:@""  options:(RKLDotAll | RKLCaseless)range:NSMakeRange(0, [meventPreview length]) error:nil];
			[meventPreview replaceOccurrencesOfRegex:@"&.+?;" withString:@""  options:(RKLDotAll | RKLCaseless)range:NSMakeRange(0, [meventPreview length]) error:nil];
			
			subjectPreview = [meventPreview retain];
		}
	}
	return subjectPreview;
}

@end
