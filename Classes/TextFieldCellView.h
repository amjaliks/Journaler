//
//  TextFieldCellView.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 24.04.10.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TextFieldCellView : UITableViewCell {
	UITextField *text;
	
	id target;
	SEL action;
}

@property (readonly) UITextField *text;
@property (nonatomic, retain) NSSet *tags;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)didEndEditing:(id)sender;

- (void)setTarget:(id)target action:(SEL)action;
	
@end
