//
//  FriendsPageTitleView.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.05.03.
//  Copyright 2010 A25. All rights reserved.
//

#import "FriendsPageTitleView.h"
#import "UIViewAdditions.h"

#import <QuartzCore/QuartzCore.h>

@implementation FriendsPageTitleView

@synthesize filterLabel;

-(id)initWithTarget:(id)target action:(SEL)action interfaceOrientation:(UIInterfaceOrientation)interfaceOrietation {
	self = [super init];
	if (self != nil) {
		[self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
		[self resizeForInterfaceOrientation:interfaceOrietation];
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		backgroundView = [[UIView alloc] initWithFrame:self.bounds];
		backgroundView.backgroundColor = [UIColor whiteColor];
		backgroundView.layer.cornerRadius = 5.0f;
		backgroundView.layer.opacity = 0.0f;
		backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; 
		[self addSubview:backgroundView];
		
		titleLabel = [[UILabel alloc] init];
		titleLabel.text = NSLocalizedString(@"Friends", nil);
		titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.shadowColor = [UIColor darkGrayColor];
		[titleLabel sizeToFit];
		[self addSubview:titleLabel];

		filterLabel = [[UILabel alloc] init];
		filterLabel.text = NSLocalizedString(@"All", nil);
		filterLabel.font = [UIFont systemFontOfSize:17.0f];
		filterLabel.backgroundColor = [UIColor clearColor];
		filterLabel.textColor = [UIColor whiteColor];
		filterLabel.shadowColor = [UIColor darkGrayColor];
		[filterLabel sizeToFit];
		[self addSubview:filterLabel];
		
		dotLabel = [[UILabel alloc] init];
		dotLabel.text = @" • ";
		dotLabel.font = [UIFont systemFontOfSize:17.0f];
		dotLabel.backgroundColor = [UIColor clearColor];
		dotLabel.textColor = [UIColor whiteColor];
		dotLabel.shadowColor = [UIColor darkGrayColor];
		[dotLabel sizeToFit];
	}
	return self;
}

- (void)layoutSubviews{
	[self resizeForInterfaceOrientation:0];
	
	if (self.highlighted) {
		backgroundView.layer.opacity = 0.3f;
	} else {
		backgroundView.layer.opacity = 0.0f;
	}
	
	if (self.bounds.size.height < 30) {
		[self addSubview:dotLabel];
		filterLabel.font = [UIFont systemFontOfSize:17.0f];
		[filterLabel sizeToFit];
		
		CGFloat offsetLeft = truncf((self.bounds.size.width - titleLabel.frame.size.width - dotLabel.frame.size.width - filterLabel.frame.size.width) / 2.0f);
		CGFloat offsetTop = truncf((self.bounds.size.height - titleLabel.frame.size.height) / 2.0f);
		
		titleLabel.frame = CGRectMake(
									  offsetLeft,
									  offsetTop,
									  titleLabel.frame.size.width,
									  titleLabel.frame.size.height);
		offsetLeft += titleLabel.frame.size.width;
		
		dotLabel.frame = CGRectMake(
									offsetLeft,
									offsetTop,
									dotLabel.frame.size.width,
									dotLabel.frame.size.height);
		offsetLeft += dotLabel.frame.size.width;
		
		filterLabel.frame = CGRectMake(
									   offsetLeft,
									   offsetTop,
									   filterLabel.frame.size.width,
									   filterLabel.frame.size.height);
	} else {
		[dotLabel removeFromSuperview];
		filterLabel.font = [UIFont systemFontOfSize:15.0f];
		[filterLabel sizeToFit];
		
		CGFloat offsetTop = truncf((self.bounds.size.height - titleLabel.frame.size.height - filterLabel.frame.size.height + 3.0f) / 2.0f) - 1.0f;
		
		titleLabel.frame = CGRectMake(
									  (self.bounds.size.width - titleLabel.frame.size.width) / 2.0f,
									  offsetTop,
									  titleLabel.frame.size.width,
									  titleLabel.frame.size.height);
		offsetTop += titleLabel.frame.size.height - 3.0f;
		
		filterLabel.frame = CGRectMake(
									   (self.bounds.size.width - filterLabel.frame.size.width) / 2.0f,
									   offsetTop,
									   filterLabel.frame.size.width,
									   filterLabel.frame.size.height);
	}
	
	[super layoutSubviews];
}

- (void)resizeForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	BOOL landscape = UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation]);
	self.frame = landscape ? CGRectMake(85, 3, 310, 26) : CGRectMake(85, 3, 150, 38);
}

@end
