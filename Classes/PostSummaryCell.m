//
//  PostSummaryCell.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.24.
//  Copyright 2009 A25. All rights reserved.
//

#import "PostSummaryCell.h"
#import "Model.h"
#import "UserPicCache.h"
#import "JournalerAppDelegate.h"

enum {
	PSSubject = 1,
	PSAuthor,
	PSDateTimeReplies,
	PSText,
	PSUserPic,
	PSCommunityIn,
	PSCommunityIcon,
	PSCommunityName
};


@implementation PostSummaryCell

@synthesize tableView;
@synthesize post;

- (void) setPost:(Post *)_post {
	post = _post;
	
    UILabel *label;
    label = (UILabel *)[self viewWithTag:PSSubject];
	if ([post.subject length]) {
		label.text = post.subjectPreview;
	} else {
		label.text = @"(no subject)";
	}
	
    label = (UILabel *)[self viewWithTag:PSAuthor];
	label.text = post.poster;
	CGRect frame = label.frame;
	if (!post.posterNameWidth) {
		CGSize size = [label sizeThatFits:frame.size];
		if ([@"C" isEqualToString:post.journalType] && size.width > 150) {
			size.width = 150;
		}
		post.posterNameWidth = size.width;
	}
	frame.size.width = post.posterNameWidth;
	label.frame = frame;
	CGFloat last = frame.origin.x + frame.size.width;
	
	UILabel *communityIn = (UILabel *)[self viewWithTag:PSCommunityIn];
	UIImageView *communityIcon = (UIImageView *)[self viewWithTag:PSCommunityIcon];
	UILabel *communityName = (UILabel *)[self viewWithTag:PSCommunityName];
	if ([@"C" isEqualToString:post.journalType] || [@"N" isEqualToString:post.journalType]) {
		communityIn.hidden = NO;
		communityIcon.hidden = NO;
		communityName.hidden = NO;
		
		frame = communityIn.frame;
		frame.origin.x = last + 1;
		communityIn.frame = frame;
		last = frame.origin.x + frame.size.width;
		
		frame = communityIcon.frame;
		frame.origin.x = last + 1;
		communityIcon.frame = frame;
		last = frame.origin.x + frame.size.width;
		
		communityName.text = post.journal;
		frame = communityName.frame;
		frame.origin.x = last + 2;
		frame.size.width = 294 - frame.origin.x;
		communityName.frame = frame;
	} else {
		communityIn.hidden = YES;
		communityIcon.hidden = YES;
		communityName.hidden = YES;
	}
	
	label = (UILabel *)[self viewWithTag:PSText];
    label.text = post.textPreview;
	
	NSDateFormatter *f = [[NSDateFormatter alloc] init];
	[f setDateStyle:NSDateFormatterShortStyle];
	[f setTimeStyle:NSDateFormatterShortStyle];
	
	label = (UILabel *)[self viewWithTag:PSDateTimeReplies];
    label.text = [NSString stringWithFormat:@"%@, %d%@ replies", [f stringFromDate:post.dateTime], [post.replyCount integerValue], post.updated ? @"" : @"*"];
	[f release];
	
	UIImageView *imageView = (UIImageView *)[self viewWithTag:PSUserPic];
	if (post.userPicURL && [post.userPicURL length]) {
		UserPicCache *userPicCache = ((JournalerAppDelegate *)[[UIApplication sharedApplication] delegate]).userPicCache;
		imageView.image = [[userPicCache imageFromURL:post.userPicURL force:NO] retain];
	} else {
		imageView.image = nil;
	}
}

- (void) setUserPic:(UIImage *)image {
	UIImageView *imageView = (UIImageView *)[self viewWithTag:PSUserPic];
	imageView.image = image;
}

@end
