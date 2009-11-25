//
//  PostPreviewView.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.23.
//  Copyright 2009 A25. All rights reserved.
//

#import "PostPreviewView.h"

#import "Macros.h"
#import "Model.h"

#define MAX_W 220

#define ICON_W 13
#define ICON_H 13
#define ICON_SPACE 2
#define LOCK_ICON_X SUBJECT_X
#define LOCK_ICON_Y 7
#define USER_ICON_X SUBJECT_X
#define USER_ICON_Y 22

#define SUBJECT_FONT_SIZE 14
#define SUBJECT_X 74
#define SUBJECT_Y 5
#define SUBJECT_W MAX_W
#define SUBJECT_H 19
#define PRIVATE_SUBJECT_X_DIFF (ICON_W + ICON_SPACE)
#define PRIVATE_SUBJECT_X (SUBJECT_X + PRIVATE_SUBJECT_X_DIFF)
#define PRIVATE_SUBJECT_W (SUBJECT_W - PRIVATE_SUBJECT_X_DIFF)

#define USER_FONT_SIZE 12
#define USER_X (USER_ICON_X + ICON_W + ICON_SPACE)
#define USER_Y 21
#define USER_W (MAX_W - ICON_W - ICON_SPACE)
#define USER_W_MAX 150
#define USER_H 15

#define COMMUNITY_FONT_SIZE USER_FONT_SIZE

#define DTR_FONT_SIZE 11
#define DTR_X SUBJECT_X
#define DTR_Y 36
#define DTR_W MAX_W
#define DTR_H 13

#define TEXT_FONT_SIZE 13
#define TEXT_X SUBJECT_X
#define TEXT_Y 49
#define TEXT_W MAX_W
#define TEXT_H 32

#define USERPIC_X 7
#define USERPIC_Y 7
#define USERPIC_W 60
#define USERPIC_H 60

@implementation PostPreviewView

@synthesize highlighted;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor whiteColor];
		
		subjectFont = [UIFont fontWithName:@"Helvetica-Bold" size:SUBJECT_FONT_SIZE];
		userFont = [UIFont fontWithName:@"Helvetica-Bold" size:USER_FONT_SIZE];
		communityFont = [UIFont systemFontOfSize:COMMUNITY_FONT_SIZE];
		dateTimeRepliesFont = [UIFont systemFontOfSize:DTR_FONT_SIZE];
		textFont = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
		
		inWidth = [@" in " sizeWithFont:communityFont].width;
		
		f = [[NSDateFormatter alloc] init];
		[f setDateStyle:NSDateFormatterShortStyle];
		[f setTimeStyle:NSDateFormatterShortStyle];		
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	UIColor *subjectColor;
	UIColor *metaDataColor;
	UIColor *textColor;
    if (self.highlighted) {
		subjectColor = [UIColor whiteColor];
		metaDataColor = [UIColor whiteColor];
		textColor = [UIColor whiteColor];
	} else {
		subjectColor = [UIColor colorWithRed:0.188 green:0.333 blue:0.482 alpha:1.0];
		metaDataColor = [UIColor colorWithRed:0.337 green:0.337 blue:0.337 alpha:1.0];
		textColor = [UIColor blackColor];
		self.backgroundColor = [UIColor whiteColor];
	}
	
	CGPoint point = CGPointMake(post.isPublic ? SUBJECT_X : PRIVATE_SUBJECT_X, SUBJECT_Y);

	//virsraksts
	NSString *subject = post.subjectPreview;
	if (!subject || ![subject length]) {
		subject = @"(no subject)";
	}
	[subjectColor set];
	[subject drawAtPoint:point forWidth:post.isPublic ? SUBJECT_W : PRIVATE_SUBJECT_W withFont:subjectFont fontSize:SUBJECT_FONT_SIZE lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	
	if (!post.isPublic) {
		// atslēdziņa
		CGRect rect = CGRectMake(LOCK_ICON_X, LOCK_ICON_Y, ICON_W, ICON_H);
		UIImage *lockIcon = [UIImage imageNamed:@"lock.png"];
		[lockIcon drawInRect:rect];
	}
	
	// lietotāja ikona
	rect = CGRectMake(USER_ICON_X, USER_ICON_Y, ICON_W, ICON_H);
	UIImage *userIcon = [UIImage imageNamed:@"user.png"];
	[userIcon drawInRect:rect];
	
	BOOL community = [@"C" isEqualToString:post.journalType] || [@"N" isEqualToString:post.journalType];
	// lietotāja vārds
	[metaDataColor set];
	if (community && !post.posterNameWidth) {
		post.posterNameWidth = [post.poster sizeWithFont:userFont].width;
		if (post.posterNameWidth > USER_W_MAX) {
			post.posterNameWidth = USER_W_MAX;
		}
	}
	
	point = CGPointMake(USER_X, USER_Y);
	[post.poster drawAtPoint:point forWidth:community ? post.posterNameWidth : USER_W withFont:userFont fontSize:USER_FONT_SIZE lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	
	if (community) {
		// "iekš"
		CGFloat x = USER_X + post.posterNameWidth;
		point = CGPointMake(x, USER_Y);
		[@" in " drawAtPoint:point forWidth:inWidth withFont:communityFont fontSize:COMMUNITY_FONT_SIZE lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
		
		// kopienas ikona
		x += inWidth;
		rect = CGRectMake(x, USER_ICON_Y, ICON_W, ICON_H);
		UIImage *userIcon = [UIImage imageNamed:@"community.png"];
		[userIcon drawInRect:rect];
		
		// kopienas nosaukums
		x += ICON_W + ICON_SPACE;
		CGFloat w = USER_ICON_X + MAX_W - x;
		point = CGPointMake(x, USER_Y);
		[post.journal drawAtPoint:point forWidth:w withFont:communityFont fontSize:COMMUNITY_FONT_SIZE lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	}
	
	// datums, laiks, komentāru skaits
	point = CGPointMake(DTR_X, DTR_Y);
    NSString *dtr = [NSString stringWithFormat:@"%@, %d%@ replies", [f stringFromDate:post.dateTime], [post.replyCount integerValue], post.updated ? @"" : @"*"];
	[dtr drawAtPoint:point forWidth:DTR_W withFont:dateTimeRepliesFont fontSize:DTR_FONT_SIZE lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	
	// teksts
	[textColor set];
	rect = CGRectMake(TEXT_X, TEXT_Y, TEXT_W, TEXT_H);
	[post.textPreview drawInRect:rect withFont:textFont lineBreakMode:UILineBreakModeTailTruncation];
	
	// userpic
	if (post.userPic) {
		rect = CGRectMake(USERPIC_X, USERPIC_Y, USERPIC_W, USERPIC_H);

		CGSize size = post.userPic.size;
		if (size.width != size.height) {
			CGFloat r = size.width / size.height;
			if (r > 1) {
				rect.size.height = rect.size.height / r;
				rect.origin.y += (USERPIC_H - rect.size.height) / 2;
			} else {
				rect.size.width = rect.size.width * r;
				rect.origin.x += (USERPIC_W - rect.size.width) / 2;
			}
		}
		
		[post.userPic drawInRect:rect];
	}
}

- (void)setHighlighted:(BOOL)lit {
	// If highlighted state changes, need to redisplay.
	if (highlighted != lit) {
		highlighted = lit;	
		[self setNeedsDisplay];
	}
}


- (void) setPost:(Post *)newPost {
	if (newPost != post) {
		post.view = nil;
		[post release];
		
		post = [newPost retain];
		post.view = self;
	}
	
	[self setNeedsDisplay];
}

- (void)dealloc {
	[post release];
	[f release];	
	
    [super dealloc];
}


@end
