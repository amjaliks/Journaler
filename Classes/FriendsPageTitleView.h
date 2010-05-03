//
//  FriendsPageTitleView.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.05.03.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FriendsPageTitleView : UIButton {
	UIView *backgroundView;
	UILabel *titleLabel;
	UILabel *filterLabel;
	UILabel *dotLabel;
}

@property (readonly) UILabel *filterLabel;

-(id)initWithTarget:(id)target action:(SEL)action interfaceOrientation:(UIInterfaceOrientation)interfaceOrietation;

@end
