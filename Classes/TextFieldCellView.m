//
//  TextFieldCellView.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 24.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import "TextFieldCellView.h"
#import "LiveJournal.h"
#import "NSSetAdditions.h"

@implementation TextFieldCellView

@synthesize text;

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
		text.returnKeyType = UIReturnKeyDone;
		[self.contentView addSubview:text];
		
		[text addTarget:self action:@selector(didEndEditing:) forControlEvents:UIControlEventEditingDidEnd | UIControlEventEditingDidEndOnExit];
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

- (void)didEndEditing:(id)sender {
	//[sender resignFirstResponder];
	[target performSelector:action withObject:self];
}

- (void)setTarget:(id)newTarget action:(SEL)newAction {
	target = newTarget;
	action = newAction;
}

- (void)setTags:(NSSet *)tags {
	NSString *list = [NSString string];
	for (LJTag * tag in [tags sortedArray]) {
		if ([list length]) {
			list = [list stringByAppendingString:@", "];
		}
		list = [list stringByAppendingString:tag.name];
	}
	
	text.text = list;
}

- (NSSet *)tags {
	// sadalam rindu pēc komatiem
	NSArray *parts = [text.text componentsSeparatedByString:@","];
	
	// jauns masīvs
	NSMutableSet *tags = [[NSMutableSet alloc] initWithCapacity:[parts count]];
	// pārlasam atsevišķus teksta gabaliņus
	for (NSString *part in parts) {
		// atmetam liekos tukšumus
		LJTag *tag = [[LJTag alloc] initWithName:part];
		if (tag.name) {
			[tags addObject:tag];
		}
		[tag release];
	}
	
	return [tags autorelease];
}

@end
