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
#import "NSStringMD5.h"
#import "NSStringLJ.h"

@implementation Post 

@dynamic journal;
@dynamic journalType;
@dynamic journalTypeOld;
@dynamic dateTime;
@dynamic text;
@dynamic subject;
@dynamic poster;
@dynamic replyCount;
@dynamic account;
@dynamic ditemid;
@dynamic userPicURL;
@dynamic isRead;
@dynamic security;
@dynamic parserVersion;
@dynamic parsedSubjectPreview;
@dynamic parsedSubjectView;
@dynamic parsedTextPreview;
@dynamic parsedTextView;

@synthesize userPic;
@synthesize view;
@synthesize posterNameWidth;
@synthesize updated;
@synthesize rendered;

- (void)dealloc {
	[userPic release];
	[self clearPreproceedStrings];
	
	[super dealloc];
}

- (NSNumber *)journalType {
	NSNumber *value = [self primitiveValueForKey:@"journalType"];
	if ([value intValue] == -1) {
		// savietojamība ar veco modeli		
		return [NSNumber numberWithInt:[LJEvent journalTypeForKey:self.journalTypeOld]];
	} else {
		return value;
	}
}

- (NSString *)uniqueKey {
	if (!uniqueKey) {
		uniqueKey = [[NSString alloc] initWithFormat:@"%@+%@+%@", self.journal, self.poster, self.ditemid];
	}
	return uniqueKey;
}

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
			
			textPreview = [textPreview removeTag:@"<lj\\s*?user=\".+?\"\\s*?/?>" replacement:@"\"(.+?)\"" format:nil];
			textPreview = [textPreview removeTag:@"<lj-cut text=\".+?\">.*?</lj-cut>" replacement:@"text=\"(.+?)\"" format:@"( %@ )"];
			textPreview = [textPreview stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
			textPreview = [textPreview stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
			textPreview = [textPreview stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
			textPreview = [textPreview stringByReplacingOccurrencesOfString:@"&ndash;" withString:@"-"];
			
			NSMutableString *meventPreview = [NSMutableString stringWithString:textPreview];
			
			[meventPreview replaceOccurrencesOfRegex:@"<br\\s*/?>" withString:@" " options:(RKLDotAll | RKLCaseless) range:NSMakeRange(0, [meventPreview length]) error:nil];
			[meventPreview replaceOccurrencesOfRegex:@"<img\\s?.*?/?>" withString:@"image" options:(RKLDotAll | RKLCaseless) range:NSMakeRange(0, [meventPreview length]) error:nil];
			[meventPreview replaceOccurrencesOfRegex:@"<lj-embed .+?/>" withString:@"video" options:(RKLDotAll | RKLCaseless) range:NSMakeRange(0, [meventPreview length]) error:nil];
			[meventPreview replaceOccurrencesOfRegex:@"<.+?>" withString:@""  options:(RKLDotAll | RKLCaseless)range:NSMakeRange(0, [meventPreview length]) error:nil];
			//[meventPreview replaceOccurrencesOfRegex:@"&.+?;" withString:@""  options:(RKLDotAll | RKLCaseless)range:NSMakeRange(0, [meventPreview length]) error:nil];

			NSArray *entities = [meventPreview componentsMatchedByRegex:@"&#([0-9]+?);" options:(RKLDotAll | RKLCaseless)range:NSMakeRange(0, [meventPreview length]) capture:1 error:nil];
			for (NSString *entity in entities) {
				NSInteger code = [entity integerValue];
				unichar unich = code;
				NSString *ch = [[NSString alloc] initWithCharactersNoCopy:&unich length:1 freeWhenDone:NO];
				[meventPreview replaceOccurrencesOfString:[NSString stringWithFormat:@"&#%d;", code] withString:ch options:0 range:NSMakeRange(0, [meventPreview length])];
			}
			entities = [meventPreview componentsMatchedByRegex:@"&#x([0-9a-f]+?);" options:(RKLDotAll | RKLCaseless)range:NSMakeRange(0, [meventPreview length]) capture:1 error:nil];
			for (NSString *entity in entities) {
				NSUInteger code;
				[[NSScanner scannerWithString:entity] scanHexInt:&code];
				unichar unich = code;
				NSString *ch = [[NSString alloc] initWithCharactersNoCopy:&unich length:1 freeWhenDone:NO];
				[meventPreview replaceOccurrencesOfString:[NSString stringWithFormat:@"&#x%@;", entity] withString:ch options:NSCaseInsensitiveSearch range:NSMakeRange(0, [meventPreview length])];
			}			

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
			textView = [textView removeTag:@"<lj\\s*?user=\".+?\"\\s*?/?>" replacement:@"\"(.+?)\"" format:nil];
			textView = [textView removeTag:@"<img\\s?.*?/?>" replacement:@"src=\"?(.+?)[\"|\\s|>]" format:@"<a href=\"%@\">@imageicon@ image</a>"];
					
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
			forward.length = [subjectPreview length];
			
			subjectPreview = [subjectPreview stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
			subjectPreview = [subjectPreview stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
			subjectPreview = [subjectPreview stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
			textPreview = [textPreview stringByReplacingOccurrencesOfString:@"&ndash;" withString:@"-"];
			
			NSMutableString *meventPreview = [NSMutableString stringWithString:subjectPreview];
			
			[meventPreview replaceOccurrencesOfRegex:@"<.+?>" withString:@""  options:(RKLDotAll | RKLCaseless)range:NSMakeRange(0, [meventPreview length]) error:nil];
			
			NSArray *entities = [meventPreview componentsMatchedByRegex:@"&#([0-9]+?);" options:(RKLDotAll | RKLCaseless)range:NSMakeRange(0, [meventPreview length]) capture:1 error:nil];
			for (NSString *entity in entities) {
				NSInteger code = [entity integerValue];
				unichar unich = code;
				NSString *ch = [[NSString alloc] initWithCharactersNoCopy:&unich length:1 freeWhenDone:NO];
				[meventPreview replaceOccurrencesOfString:[NSString stringWithFormat:@"&#%d;", code] withString:ch options:0 range:NSMakeRange(0, [meventPreview length])];
			}
			entities = [meventPreview componentsMatchedByRegex:@"&#x([0-9a-f]+?);" options:(RKLDotAll | RKLCaseless)range:NSMakeRange(0, [meventPreview length]) capture:1 error:nil];
			for (NSString *entity in entities) {
				NSUInteger code;
				[[NSScanner scannerWithString:entity] scanHexInt:&code];
				unichar unich = code;
				NSString *ch = [[NSString alloc] initWithCharactersNoCopy:&unich length:1 freeWhenDone:NO];
				[meventPreview replaceOccurrencesOfString:[NSString stringWithFormat:@"&#x%@;", entity] withString:ch options:NSCaseInsensitiveSearch range:NSMakeRange(0, [meventPreview length])];
			}			
			
			[meventPreview replaceOccurrencesOfRegex:@"&.+?;" withString:@""  options:(RKLDotAll | RKLCaseless)range:NSMakeRange(0, [meventPreview length]) error:nil];

			subjectPreview = [meventPreview retain];
		}
	}
	return subjectPreview;
}

- (NSString *) userPicURLHash {
	if (!userPicURLHash && self.userPicURL) {
		userPicURLHash = [[self.userPicURL MD5Hash] retain];
	}
	return userPicURLHash;
}

- (void) clearPreproceedStrings {
	@synchronized(self) {
		[textPreview release];
		textPreview = nil;
		[textView release];
		textView = nil;
		[subjectPreview release];
		subjectPreview = nil;
		[userPicURLHash release];
		userPicURLHash = nil;
		[rendered release];
		rendered = nil;
	}
}

- (BOOL) isPublic {
	return [@"public" isEqual:self.security] || !self.security || ![self.security length];
}

@end
