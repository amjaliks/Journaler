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
#import "LiveJournal.h"

//#define kMaxWidth 220
#define kRightOffset 26											// attālums no labās malas

#define kIconWidth 13											// ikonas platums
#define kIconHeight 13											// ikonas augstums
#define kIconSpace 2											// attālums no ikonas līdz tekstam
#define kLockIconX kSubjectX									// ikonas "slēdzene" X koordināte
#define kLockIconY 7											// ikonas "slēdzene" Y koordināte
#define kUserIconX kSubjectX									// ikonas "lietotājs" X koordināte
#define kUserIconY 22											// ikonas "lietotājs" Y koordināte

#define kSubjectFontSize 14										// virsraksta burtu izmērs
#define kSubjectX 74											// virsraksta X koordināte
#define kSubjectY 5												// virsraksta Y koordināte
//#define kSubjectWidth kMaxWidth									// virsraksta platums (šo jāmaina)
//#define SUBJECT_H 19
#define kPrivateSubjectXDiff (kIconWidth + kIconSpace)			// starpība starp publiskā un privātā raksta virsraksta X koordināti
#define kPrivateSubjectX (kSubjectX + kPrivateSubjectXDiff)		// privāta raksta virsraksta X koordināte
//#define kPrivateSubjectWidth (kSubjectWidth - kPrivateSubjectXDiff) // privāta raksta virsraksta platums (šo jāmaina)

#define USER_FONT_SIZE 12
#define USER_X (kUserIconX + kIconWidth + kIconSpace)
#define USER_Y 21
// cUserWidth
// cUserMaxWidth
#define USER_H 15

#define COMMUNITY_FONT_SIZE USER_FONT_SIZE

#define DTR_FONT_SIZE 11
#define DTR_X kSubjectX
#define DTR_Y 36
// cDateTimeRepliesWidth
#define DTR_H 13

#define TEXT_FONT_SIZE 13
#define TEXT_X kSubjectX
#define TEXT_Y 49
// cTextWidth
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
		
		subjectFont = [UIFont fontWithName:@"Helvetica-Bold" size:kSubjectFontSize];
		userFont = [UIFont fontWithName:@"Helvetica-Bold" size:USER_FONT_SIZE];
		communityFont = [UIFont systemFontOfSize:COMMUNITY_FONT_SIZE];
		dateTimeRepliesFont = [UIFont systemFontOfSize:DTR_FONT_SIZE];
		textFont = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
		
		inWidth = [@" in " sizeWithFont:communityFont].width;
		
		f = [[NSDateFormatter alloc] init];
		[f setDateStyle:NSDateFormatterShortStyle];
		[f setTimeStyle:NSDateFormatterShortStyle];
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		self.clearsContextBeforeDrawing = NO;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	CGFloat cMaxWidth = self.bounds.size.width - kSubjectX - kRightOffset;	// maksimālais platums
	CGFloat cSubjectWidth = cMaxWidth;										// virsraksta platums
	CGFloat cPrivateSubjectWidth = cSubjectWidth - kPrivateSubjectXDiff;	// privāta raksta virsraksta platums
	
	CGFloat cUserWidth = cMaxWidth;											// lietotāja vārda platums
	CGFloat cDateTimeRepliesWidth = cMaxWidth;								// datuma, laika un atbilžu joslas platums
	CGFloat cTextWidth = cMaxWidth;											// teksta platums
	
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
		
		// nokrāsojam fonu
		[[post.isRead boolValue] ? [UIColor whiteColor] : [UIColor colorWithRed:0.773 green:0.851 blue:0.482 alpha:0.40] set];
		CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
	}
	
	CGPoint point = CGPointMake(post.isPublic ? kSubjectX : kPrivateSubjectX, kSubjectY);

	//virsraksts
	NSString *subject = post.subjectPreview;
	if (!subject || ![subject length]) {
		subject = @"(no subject)";
	}
	[subjectColor set];
	[subject drawAtPoint:point forWidth:post.isPublic ? cSubjectWidth : cPrivateSubjectWidth withFont:subjectFont fontSize:kSubjectFontSize lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	
	if (!post.isPublic) {
		// atslēdziņa
		CGRect rect = CGRectMake(kLockIconX, kLockIconY, kIconWidth, kIconHeight);
		UIImage *lockIcon = [UIImage imageNamed:@"lock.png"];
		[lockIcon drawInRect:rect];
	}
	
	// lietotāja ikona
	rect = CGRectMake(kUserIconX, kUserIconY, kIconWidth, kIconHeight);
	UIImage *userIcon = [UIImage imageNamed:@"user.png"];
	[userIcon drawInRect:rect];
	
	BOOL community = [post.journalType intValue] != LJJournalTypeJournal;
	// lietotāja vārds
	[metaDataColor set];
	if (community && !post.posterNameWidth) {
		CGFloat cUserMaxWidth = cMaxWidth * 0.68f; // maksimāls platums, ko drīkst aizņemt lietotāja vārds
		post.posterNameWidth = [post.poster sizeWithFont:userFont].width;
		if (post.posterNameWidth > cUserMaxWidth) {
			post.posterNameWidth = cUserMaxWidth;
		}
	}
	
	point = CGPointMake(USER_X, USER_Y);
	[post.poster drawAtPoint:point forWidth:community ? post.posterNameWidth : cUserWidth withFont:userFont fontSize:USER_FONT_SIZE lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	
	if (community) {
		// "iekš"
		CGFloat x = USER_X + post.posterNameWidth;
		point = CGPointMake(x, USER_Y);
		[@" in " drawAtPoint:point forWidth:inWidth withFont:communityFont fontSize:COMMUNITY_FONT_SIZE lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
		
		// kopienas ikona
		x += inWidth;
		rect = CGRectMake(x, kUserIconY, kIconWidth, kIconHeight);
		UIImage *userIcon = [UIImage imageNamed:@"community.png"];
		[userIcon drawInRect:rect];
		
		// kopienas nosaukums
		x += kIconWidth + kIconSpace;
		CGFloat w = kUserIconX + cMaxWidth - x;
		point = CGPointMake(x, USER_Y);
		[post.journal drawAtPoint:point forWidth:w withFont:communityFont fontSize:COMMUNITY_FONT_SIZE lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	}
	
	// datums, laiks, komentāru skaits
	point = CGPointMake(DTR_X, DTR_Y);
    NSString *dtr = [NSString stringWithFormat:@"%@, %d%@ replies", [f stringFromDate:post.dateTime], [post.replyCount integerValue], post.updated ? @"" : @"*"];
	[dtr drawAtPoint:point forWidth:cDateTimeRepliesWidth withFont:dateTimeRepliesFont fontSize:DTR_FONT_SIZE lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	
	// teksts
	[textColor set];
	rect = CGRectMake(TEXT_X, TEXT_Y, cTextWidth, TEXT_H);
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
