//
//  ListInputCellView.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 20.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import "TagsCellView.h"


@implementation TagsCellView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
#ifndef LITEVERSION
		self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
#endif
		self.textLabel.backgroundColor = [UIColor clearColor];
		
		text = [[UITextField alloc] init];
		text.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		text.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
		text.placeholder = NSLocalizedString(@"separated by commas", nil);
		text.returnKeyType = UIReturnKeyDone;
		[self.contentView addSubview:text];

		[text addTarget:self action:@selector(tagsEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd | UIControlEventEditingDidEndOnExit];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat offset = self.textLabel.frame.origin.x;
	offset += [self.textLabel.text sizeWithFont:self.textLabel.font].width;
	offset += 10.0f;
	
	text.frame = CGRectMake(offset, 6.0f, self.contentView.bounds.size.width - offset - 3.0f, 32.0f);
}


- (void)dealloc {
    [super dealloc];
	
	[text release];
}

- (void)setTags:(NSArray *)tags {
	NSString *list = [NSString string];
	for (NSString * tag in tags) {
		if ([list length]) {
			list = [list stringByAppendingString:@", "];
		}
		list = [list stringByAppendingString:tag];
	}
	
	text.text = list;
}

- (NSArray *)tags {
	NSArray *parts = [text.text componentsSeparatedByString:@","];
	
	NSMutableArray *tags = [[NSMutableArray alloc] initWithCapacity:[parts count]];
	for (NSString *part in parts) {
		NSString *tag = [part stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		if ([tag length]) {
			[tags addObject:tag];
		}
	}
	
	return [tags autorelease];
}

- (void)tagsEditingDidEnd:(id)sender {
	[sender resignFirstResponder];
	[target performSelector:action withObject:self];
}

- (void)setTarget:(id)newTarget action:(SEL)newAction {
	target = newTarget;
	action = newAction;
}


@end
