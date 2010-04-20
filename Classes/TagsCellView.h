//
//  ListInputCellView.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 20.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TagsCellView : UITableViewCell {
	UITextField *text;
	
	id target;
	SEL action;
}

@property (retain, nonatomic) NSArray *tags;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)tagsEditingDidEnd:(id)sender;

- (void)setTarget:(id)target action:(SEL)action;

@end
