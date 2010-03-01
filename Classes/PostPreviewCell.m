//
//  PostPreviewCell.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.11.23.
//  Copyright 2009 A25. All rights reserved.
//

#import "PostPreviewCell.h"
#import "PostPreviewView.h"


@implementation PostPreviewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		CGRect frame = CGRectMake(0, 0, 320, 88);
		self.frame = frame;
        view = [[PostPreviewView alloc] initWithFrame:frame];
		[self.contentView addSubview:view];
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setPost:(Post *)post {
	[view setPost:post];
}

- (void)dealloc {
	[view release];
    [super dealloc];
}


@end
